#!/usr/bin/env node
// Inventory one season of the web scouting form (www/<season>/scout.html + scout.js)
// so the matching Flutter season module (app/lib/seasons/<season>/) can be written from it.
// Prints JSON to stdout. No dependencies.
//
// usage: node .agents/skills/viper-mobile-season/extract-web-season.mjs <season> [--against <otherSeason>] [--web <webRoot>]
//   inventory:  node .agents/skills/viper-mobile-season/extract-web-season.mjs 2025-26
//   diff:       node .agents/skills/viper-mobile-season/extract-web-season.mjs 2025-26 --against 2024-25
//   The diff lists what each season has that the other does not.

import { readFileSync, existsSync, readdirSync } from 'node:fs'
import { join, resolve } from 'node:path'

const argv = process.argv.slice(2)
function option(name) {
	const i = argv.indexOf(name)
	return i >= 0 ? argv[i + 1] : null
}
const against = option('--against')
const webOption = option('--web')
const season = argv.find((a, i) => !a.startsWith('--') && argv[i - 1] !== '--against' && argv[i - 1] !== '--web')

if (!season) {
	console.error('usage: extract-web-season.mjs <season> [--against <otherSeason>] [--web <webRoot>]')
	process.exit(2)
}
// This file is at <viper>/.agents/skills/viper-mobile-season/, so <viper>/www is three levels up
const webRoot = resolve(webOption ?? join(import.meta.dirname, '../../../www'))

function inventory(seasonName) {
	const seasonDir = join(webRoot, seasonName)
	const htmlPath = join(seasonDir, 'scout.html')
	const jsPath = join(seasonDir, 'scout.js')
	if (!existsSync(htmlPath)) {
		throw new Error(`no scout.html in ${seasonDir}`)
	}

	// scout.js in the season folder is optional. The shared www/scout.js applies to every season.
	const html = readFileSync(htmlPath, 'utf8')
	const seasonScoutJs = existsSync(jsPath)
	const js = seasonScoutJs ? readFileSync(jsPath, 'utf8') : ''

	// Parse "name=value", "name='value'", "name=\"value\"", or bare "name" into an object
	function attrs(tagBody) {
		const out = {}
		for (const m of tagBody.matchAll(/([\w-]+)(?:=("[^"]*"|'[^']*'|[^\s>]+))?/g)) {
			out[m[1]] = m[2] == null ? true : m[2].replace(/^["']|["']$/g, '')
		}
		return out
	}

	// Walk every tag in the form, tracking which tab-content section we are inside
	const tags = [...html.matchAll(/<([a-zA-Z][\w-]*)\b([^>]*)>/g)].map(m => ({
		name: m[1].toLowerCase(),
		attrs: attrs(m[2]),
		index: m.index + m[0].length,
	}))

	const sectionIds = ['pre', 'auto', 'teleop', 'end']
	let section = null
	const tabs = []
	const counters = new Map() // name -> record
	const checkboxes = []
	const textInputs = []

	// The label text for an input is the first data-i18n key that follows it before the next tag
	function nextI18n(index) {
		const slice = html.slice(index, index + 300)
		const m = slice.match(/data-i18n=([\w]+)/)
		const beforeNextInput = slice.split(/<input|<button/)[0]
		return m && beforeNextInput.includes(m[0]) ? m[1] : null
	}

	for (const t of tags) {
		const cls = (t.attrs.class ?? '').toString().split(/\s+/)
		if (t.name === 'div' && cls.includes('tab-content')) {
			section = cls.find(c => sectionIds.includes(c)) ?? section
		}
		if (t.name === 'div' && cls.includes('tab') && t.attrs['data-content']) {
			tabs.push({ id: t.attrs['data-content'], labelKey: t.attrs['data-i18n'] ?? null, default: cls.includes('default-tab') })
		}
		if (t.name === 'button' && cls.includes('count') && t.attrs['data-input']) {
			const name = t.attrs['data-input']
			const rec = counters.get(name) ?? { name, section, buttons: 0, inputs: 0 }
			rec.buttons++
			counters.set(name, rec)
			// A button whose content is a text label (e.g. "+1") rather than an image
			rec.button = /<span>/.test(html.slice(t.index, t.index + 80)) ? 'text' : 'image'
		}
		if (t.name === 'input' && t.attrs.type === 'checkbox') {
			checkboxes.push({ name: t.attrs.name, value: t.attrs.value ?? null, section, labelKey: nextI18n(t.index) })
		}
		if (t.name === 'input' && t.attrs.type === 'text' && (cls.includes('num') || t.attrs.name)) {
			if (cls.includes('num') && t.attrs.name) {
				const rec = counters.get(t.attrs.name) ?? { name: t.attrs.name, section, buttons: 0, inputs: 0 }
				rec.inputs++
				counters.set(t.attrs.name, rec)
			} else {
				textInputs.push({ name: t.attrs.name ?? null, id: t.attrs.id ?? null, section, placeholder: t.attrs.placeholder ?? null })
			}
		}
		if (t.name === 'input' && t.attrs.type === 'hidden') {
			textInputs.push({ name: t.attrs.name ?? null, id: t.attrs.id ?? null, section: 'hidden', hidden: true })
		}
	}

	// Counter names are reported as written. The period comes from the auto_/tele_ prefix.
	const counterRows = [...counters.values()].map(c => {
		const m = c.name.match(/^(auto|tele)_(.+)$/)
		return { ...c, period: m ? m[1] : null, stem: m ? m[2] : c.name }
	}).sort((a, b) => a.name.localeCompare(b.name))

	// Numeric constants and timing from scout.js (caps, preloads, auto length, delays)
	const constants = [...js.matchAll(/\b([A-Z][A-Z0-9_]*)\s*=\s*(\d+)\b/g)].map(m => ({ name: m[1], value: Number(m[2]) }))
	const timeouts = [...js.matchAll(/setTimeout\([^;]*?,\s*([A-Z0-9_]+|\d+)\)/g)].map(m => m[1])
	const functions = [...js.matchAll(/function\s+(\w+)\s*\(/g)].map(m => m[1])

	// Translation keys defined in the addI18n({...}) block in scout.js
	const i18nKeys = [...js.matchAll(/^\t(\w+):\s*\{/gm)].map(m => m[1])

	// Fields that the shared www/scout.js injects into every season's form (scouter, comments,
	// review request, created/modified). They are not in the season's scout.html.
	const sharedJs = readFileSync(join(webRoot, 'scout.js'), 'utf8')
	function functionBody(name) {
		const start = sharedJs.indexOf(`function ${name}(`)
		if (start < 0) return ''
		const next = sharedJs.indexOf('\nfunction ', start + 10)
		return sharedJs.slice(start, next < 0 ? undefined : next)
	}
	const sharedInjected = []
	for (const fn of ['scoutNameHtml', 'setupScouterSections']) {
		for (const m of functionBody(fn).matchAll(/<(input|textarea|select)\b([^>]*)>/g)) {
			const a = attrs(m[2])
			if (a.name) sharedInjected.push({ name: a.name, tag: m[1], type: a.type ?? null, fromFunction: fn })
		}
	}

	// Hooks that the shared www/scout.js provides, and the ones this season's scout.js registers on
	const sharedHooks = [...new Set([...sharedJs.matchAll(/window\.(on\w+)\s*=\s*window\.\1\s*\|\|/g)].map(m => m[1]))]
	const hooksRegistered = [...new Set([...js.matchAll(/window\.(\w+)\.push\(/g)].map(m => m[1]))]

	return {
		season: seasonName,
		sourceDir: seasonDir,
		seasonScoutJs,
		sharedHooks,
		hooksRegistered,
		tabs,
		counters: counterRows,
		checkboxes,
		textInputs,
		sharedInjected,
		constants,
		timeouts,
		functions,
		i18nKeys,
		instructionFiles: readdirSync(seasonDir).filter(f => f.endsWith('.md')),
		images: readdirSync(seasonDir).filter(f => /\.(png|jpe?g|svg)$/i.test(f)),
	}
}

// Keys that identify an item in each list, so two seasons can be compared item by item
const keyOf = {
	tabs: t => t.id,
	counters: c => c.name,
	checkboxes: c => c.name,
	textInputs: t => t.name ?? t.id,
	sharedInjected: s => s.name,
	constants: c => c.name,
	functions: f => f,
	i18nKeys: k => k,
	images: f => f,
}

function diff(a, b) {
	const out = {}
	for (const list of Object.keys(keyOf)) {
		const keysA = new Set(a[list].map(keyOf[list]))
		const keysB = new Set(b[list].map(keyOf[list]))
		out[list] = {
			onlyIn: [...keysA].filter(k => !keysB.has(k)),
			onlyInAgainst: [...keysB].filter(k => !keysA.has(k)),
		}
	}
	return out
}

try {
	const main = inventory(season)
	if (against) {
		const other = inventory(against)
		console.log(JSON.stringify({ season, against, diff: diff(main, other) }, null, 2))
	} else {
		console.log(JSON.stringify(main, null, 2))
	}
} catch (e) {
	console.error(e.message)
	process.exit(1)
}
