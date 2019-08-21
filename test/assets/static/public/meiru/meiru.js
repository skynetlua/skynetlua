
var assert = console.assert;
var log    = console.log;

//MeiruWidget
var MeiruWidget = (function() {
	var create_widget;
	function Widget(name) {
		this._name = name;
	}
	Widget.prototype = {
		set: function() {
			for (var i = 0, len = arguments.length; i < len; i++) {
				var arg = arguments[i];
				if (arg instanceof Widget) {
					this._childs = this._childs || [];
					this._childs.push(arg);
				} else {
					if (typeof(arg) === "string") {
						this._text = arg;
					} else if (typeof(arg) === "number") {
						this._text = arg.toString();
					} else if (typeof(arg) === "object") {
						this._props = this._props || {};
						for (k in arg) {this._props[k] = arg[k];}
					}else{
						assert(false);
					}
				}
			}
			return this;
		},
		addchild:function(child) {
			this._childs = this._childs || [];
			this._childs.push(child);
			return this;
		},
		new:function() {
			var child = create_widget.apply(null, arguments);
			this.addchild(child);
			return child;
		},
		batch:function(name, args) {
			var arg;
			var child;
			for (var i = 0; i < args.length; i++) {
				arg = args[i];
				child = create_widget(name);
				if (typeof(arg) == "string" || typeof(arg) == "number") {
					child.set(arg);
				}else if (typeof(arg) === "object"){
					child.set.apply(child, arg);
				}else{
					assert(false);
				}
				this.addchild(child);
			}
			return this;
		},
		setprop:function(key, val) {
			this._props = this._props || {};
			if (arguments.length <= 2) {
				this._props[key] = val;
			}else{
				assert(arguments.length%2 == 0);
				for (var i = 0, len = arguments.length; i < len; i+=2) {
					this._props[arguments[i]] = arguments[i+1];
				}
			}
			return this;
		},
		echo: function() {
			if(this._name === "txt"){
				var retval = self._text || "";
				if (this._childs){
					for (var i = 0, len = this._childs.length; i < len; i++) {
						retval = retval+this._childs[i].echo();
					}
				}
				return retval;
			}
			var retval = "<" + this._name + " ";
			if (this._props) {
				for (k in this._props) {
					if (typeof(this._props[k]) === "string") {
						retval = retval+k+"=\""+this._props[k]+"\" ";
					} else {
						retval = retval+k+"="+this._props[k]+" ";
					}
				}
			}
			if (!this._text && !this._childs) {
				return retval + "/>";
			}
			retval = retval+ ">"+ (this._text || "")
			if (this._childs) {
				for (var i = 0, len = this._childs.length; i < len; i++) {
					retval = retval + this._childs[i].echo();
				}
			}
			return retval+ "</"+ this._name+">";
		},
		goodecho: function(sep, depth) {
			sep = sep || "\n";
			depth = depth || 0;
			var indent = "";
			for (var i = 0; i < depth; i++) {indent = indent+"	";}
			if(this._name === "txt"){
				var retval = indent+(self._text || "");
				if (this._childs){
					for (var i = 0, len = this._childs.length; i < len; i++) {
						retval = retval+this._childs[i].echo();
					}
				}
				return retval;
			}
			var props = "";
			if (this._props) {
				for (k in this._props) {
					if (typeof(this._props[k]) === "string") {
						props = props+k+"=\""+this._props[k]+"\" ";
					} else {
						props = props+k+"="+this._props[k]+" ";
					}
				}
			}
			if (!this._text && !this._childs) {
				return indent+"<"+this._name+" "+props+"/>"+sep;
			}
			var preseq = sep;
			var suindent = indent;
			var retval = this._text || "";
			if (this._childs) {
				for (var i = 0, len = this._childs.length; i < len; i++) {
					retval = retval+this._childs[i].goodecho(sep, depth + 1);
				}
			} else {
				preseq = "";
				suindent = "";
			}
			return indent+"<"+this._name+" "+props+">"+preseq+retval+suindent+"</"+this._name+">"+sep;
		},
		show:function(id) {
			document.getElementById(id).innerHTML = this.echo();
		}
	};
	create_widget = function(name) {
		var wgt = new Widget(name);
		if (arguments.length > 1) {
			wgt.set.apply(wgt, [].slice.call(arguments, 1));
		}
		return wgt;
	};
	return create_widget;
})();

//MeiruSocket
function MeiruSocket(user) {
	this.user = user;
}

MeiruSocket.prototype = {
	connect:function(ws_url) {
		if (!("WebSocket" in window)) {
			alert("此浏览器不支持WebSocket");
			return;
		}
		var ws = new WebSocket(ws_url);
		this.ws = ws;
		var self = this;
		ws.onerror = function(){
			self.user.command("network_error");
	    };
	    ws.onopen = function() {
			self.user.command("network_open");
	    };
	    ws.onmessage = function(event) {
			var data = event.data
			self.user.command("network_message", data.length);
			self.dispatch(data);
	    };
	    ws.onclose = function() {
			self.user.command("network_close");
	    };
	},
	dispatch:function(data) {
		this.user.dispatch(data);
	},
	send:function(data) {
		this.ws.send(data);
	}
}

//Dispatcher
function MeiruDispatcher(user) {
	this.user = user;
	this.commands = {};
	this.requests = {};
	this.responses = {};
	this.triggers = {};
}

MeiruDispatcher.prototype = {
	add_module:function(name, m){
		if(m.command){
			for (var key in m.command) {
				assert(!this.commands[key], "["+name+"]module command error:"+key);
				this.commands[key] = m.command[key];
			}
		}
		if(m.request){
			for (var key in m.request) {
				assert(!this.requests[key], "["+name+"]module request error:"+key);
				this.requests[key] = m.request[key];
			}
		}
		if(m.response){
			for (var key in m.response) {
				assert(!this.responses[key], "["+name+"]module response error:"+key);
				this.responses[key] = m.response[key];
			}
		}
		if(m.trigger){
			for (var key in m.trigger) {
				assert(!this.triggers[key], "["+name+"]module trigger error:"+key);
				this.triggers[key] = m.trigger[key];
			}
		}
	},

	send:function(name, proto){

	},

	command:function(name){
		var command = this.commands[name]
		if (command){
			command.apply(this.user, [].slice.call(arguments, 1));
		}else{
			log("Dispatcher:command not implement:", name);
		}
	},

 	request:function(name){
		var request = this.requests[name]
		if(request){
			request.apply(this.user, [].slice.call(arguments, 1))
		}else{
			log("Dispatcher:request not implement:", name)
		}
	},

	response:function(name, proto){
		var response = this.responses[name]
		if(response){
			response.call(this.user, proto)
		}else{
			log("Dispatcher:response not implement:", name)
		}
	},

	trigger:function(name, data){
		for (var key in this.triggers) {
			this.triggers[key].call(this.user, name, data)
		}
	}
};


// function MeiruModel() {

// }

// MeiruModel.prototype = {
// 	set: function() {

// 	},
// 	get:function() {

// 	}
// }

//MeiruUser
function Meiru() {
	this.ws = new MeiruSocket(this);
	this.dispatcher = new MeiruDispatcher(this);
}

Meiru.prototype = {
	start:function(ws_url) {
		var modules = Meiru._modules;
		for (var key in modules) {
			this.dispatcher.add_module(key, modules[key]());
		}
		this.ws.connect(ws_url);
	},

	send:function(name, proto, errno){
	    assert(name.length<255);
	    var data = String.fromCharCode(errno || 0)+String.fromCharCode(name.length)+name;
	    if(proto){
	        data = data+JSON.stringify(proto);
	    }
	    log("Meiru:send data=", data);
	    this.ws.send(data)
	},

	command:function(){
		this.dispatcher.command.apply(this.dispatcher, arguments);
	},

	request:function(name, proto){
		this.dispatcher.request(name, proto);
	},

	trigger:function(name, data){
		this.dispatcher.trigger(name, data);
	},

	dispatch:function(data){
		if(data.length > 0){
			var msg_idx = data.charCodeAt(0);
			if (this.msg_idx) {
				if (this.msg_idx+1 != msg_idx) {
					if (msg_idx == 1) {
						assert(this.msg_idx == 255,"msg_idx ="+msg_idx+"this.msg_idx="+this.msg_idx);
					}else{
						assert(false,"msg_idx ="+msg_idx+"this.msg_idx="+this.msg_idx);
					}
				}
			}
			this.msg_idx = msg_idx;
			var len = data.charCodeAt(1);
			var pos = len+2;
	    	if (pos <= data.length){
	    		var name = data.substring(2, pos);
	    		var proto;
	    		if (pos < data.length){
	    			proto = JSON.parse(data.substring(pos));
	    		}
	    		log("Meiru.dispatch name=", name, "proto =", proto);
	    		this.dispatcher.response(name, proto || {});
	    	}else{
	    		log("Meiru.dispatch illegal data package!!!");
	    	}
		}else{
	    	log("Meiru.dispatch illegal data package!!!");
		}
	}
}

Meiru.widget = MeiruWidget;

Meiru.menu = function (cb) {
	var meiru_menus = document.getElementsByClassName('meiru-menu');
	for (var i = 0; i < meiru_menus.length; i++) {
		(function() {
			var meiru_menu = meiru_menus[i];
			var meiru_items = meiru_menu.getElementsByClassName('meiru-menu-item');
			for (var j = 0; j < meiru_items.length; j++) {
				(function() {
					var idx = j;
					var meiru_item = meiru_items[j];
					meiru_item.addEventListener('click', function(e) {
						cb(event, idx, meiru_menu, meiru_item);
					})
				})();
			}
		})();
	}
}

Meiru.modules = function(mname, cname, com) {
	var modules = Meiru._modules;
	if (!modules) {
		modules = {};
		Meiru._modules = modules;
	}
	if (!mname) {
		return modules;
	}
	var m = modules[mname];
	if (!m) {
		m = {};
		modules[mname] = m;
	}
	if (!cname) {
		return m;
	}
	if (typeof(cname) != "string") {
		modules[mname] = cname;
		return cname;
	}
	var c = m[cname]
	if (!c) {
		assert(cname == 'command' 
			|| cname == 'request'
			|| cname == 'response'
			|| cname == 'trigger'
			)
		if (com) {
			c = com;
		}else{
			c = {};
		}
		m[cname] = c;
	}else{
		c = com;
		m[cname] = c;
	}
	return c;
};




Meiru.models = function(vname, vobj) {

};

Meiru.views = function(vname, vobj) {

};
// var cmd = meiru.module("menu", "cmd")
