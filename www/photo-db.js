"use strict"

class PhotoDB{
	constructor(cb){
		cb??=(_=>{})
		var r=indexedDB.open("photos",2)
		r.onupgradeneeded=e=>e.target.result.createObjectStore("photos",{keyPath:"key"})
		r.onsuccess=e=>{this.idb=e.target.result;cb(e)}
		r.onerror=e=>{console.error(e);cb(e)}
	}

	transaction(){
		return this.idb.transaction("photos","readwrite").objectStore("photos")
	}

	put(key,data,cb){
		cb??=(_=>{})
		if(!this.idb&&/^(deleted|uploaded)_20[0-9]{2}_photo_/.test(key))return cb()
		if(!this.idb||!/_photo_/.test(key))return cb(localStorage[key]=data)
		localStorage[key]='idb'+new Date().toISOString().replace(/\..*/,"+00:00")
		var r=this.transaction().put({key:key,data:data})
		r.onsuccess=e=>cb(e)
		r.onerror=e=>{console.error(e);cb(e)}
	}

	get(key,cb){
		cb??=(_=>{})
		var l=localStorage[key]
		if(!/^idb(20|$)/.test(l))return cb(l)
		if(!this.idb)return cb()
		var r=this.transaction().get(key)
		r.onsuccess=e=>cb(e.target.result.data)
		r.onerror=e=>{console.error(e);cb()}
	}

	delete(key,cb){
		cb??=(_=>{})
		localStorage.removeItem(key)
		if(!this.idb)return cb()
		var r=this.transaction().delete(key)
		r.onsuccess=e=>cb(e)
		r.onerror=e=>{console.error(e);cb(e)}
	}

	rename(oldKey,newKey,cb){
		this.get(oldKey,d=>this.put(newKey,d,_=>this.delete(oldKey,cb)))
	}
}
var pdb=new PhotoDB()
