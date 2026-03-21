"use strict"

class PhotoDB{
	constructor(cb){
		cb??=(_=>{})
		this.ready=new Promise((resolve,reject)=>{
			var r=indexedDB.open("photos",2)
			r.onupgradeneeded=e=>e.target.result.createObjectStore("photos",{keyPath:"key"})
			r.onsuccess=e=>{this.idb=e.target.result;resolve(e);cb(e)}
			r.onerror=e=>{console.error(e);reject(e);cb(e)}
		})
	}

	transaction(){
		return this.idb.transaction("photos","readwrite").objectStore("photos")
	}

	resolveIdbKey(key,cb){
		// Try to find key in IndexedDB, with or without prefix
		var r=this.transaction().get(key)
		r.onsuccess=e=>{
			if(e.target.result){
				cb(key) // Found with original key
			} else {
				// Try without prefix (backwards compatibility for prefixed stored photos)
				var idbKey = key.replace(/^(deleted|uploaded)_/, '')
				if(idbKey !== key){
					var r2=this.transaction().get(idbKey)
					r2.onsuccess=e2=>cb(e2.target.result ? idbKey : null)
					r2.onerror=e2=>cb(null)
				} else {
					cb(null)
				}
			}
		}
		r.onerror=e=>cb(null)
	}

	put(key,data,cb){
		cb??=(_=>{})
		if(/_photo_/.test(key)){
			this.ready.then(()=>{
				if(!this.idb)return cb()
				localStorage[key]='idb'+new Date().toISOString().replace(/\..*/,"+00:00")
				var r=this.transaction().put({key:key,data:data})
				r.onsuccess=e=>cb(e)
				r.onerror=e=>{console.error(e);cb(e)}
			}).catch(e=>cb())
		}else{
			cb(localStorage[key]=data)
		}
	}

	get(key,cb){
		cb??=(_=>{})
		var l=localStorage[key]
		if(!/^idb(20|$)/.test(l))return cb(l)
		this.ready.then(()=>{
			if(!this.idb)return cb()
			this.resolveIdbKey(key, idbKey => {
				if(!idbKey) return cb()
				var r=this.transaction().get(idbKey)
				r.onsuccess=e=>cb(e.target.result?.data)
				r.onerror=e=>{console.error(e);cb()}
			})
		}).catch(e=>cb())
	}

	delete(key,cb){
		cb??=(_=>{})
		localStorage.removeItem(key)
		this.ready.then(()=>{
			if(!this.idb)return cb()
			this.resolveIdbKey(key, idbKey => {
				if(!idbKey) return cb()
				var r=this.transaction().delete(idbKey)
				r.onsuccess=e=>cb(e)
				r.onerror=e=>{console.error(e);cb()}
			})
		}).catch(e=>cb())
	}
}
var pdb=new PhotoDB()
