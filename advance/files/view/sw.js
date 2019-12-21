'use strict';
'require ui';
'require uci';
'require rpc';
'require form';
return L.view.extend({

	load: function() {
		return Promise.all([
			uci.load('luci'),
			uci.load('system')
		]);
	},

	render: function() {
		var sw_enabled,m, s, o;

		m = new form.Map('wifimedia');

		s = m.section(form.TypedSection, 'switchmode', _('Switch Mode'));
		s.anonymous = true;
		s.addremove = true;
	
		o = s.option(form.Flag,'switch_port',_('All Port LAN & WAN'));
		o.rmempty = false;
		o.write = function(section_id, value) {
			sw_enabled = +value;
			if (!sw_enabled)
			uci.set('wifimedia', '@switchmode[0]', 'switch_port','1')
		};
		o.load = function(section_id) {
			return (sw_enabled == 1 &&
				uci.get('wifimedia', '@switchmode[0]') != null &&
				uci.get('wifimedia', '@switchmode[0]', 'switch_port') != 0) ? '1' : '0';
			};

		return m.render();
	}
});
