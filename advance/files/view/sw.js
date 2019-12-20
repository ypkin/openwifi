'use strict';
'require fs';
'require ui';
'require uci';
'require form';
'require network';
'require tools.widgets as widgets';

return L.view.extend({

	render: function() {
		var m, s, o;

		m = new form.Map('wifimedia');

		s = m.section(form.TypedSection, 'switchmode', _('Switch Mode'));
		s.anonymous = true;
		s.addremove = true;
	
		o = s.option(form.Flag,"switch_port","All Port LAN & WAN")
		o.rmempty = false
		o.write = function(section_id, value){
			sw_port_enable = +value
			if(!sw_port_enable){
					uci.del('network','lan');
					uci.set('network','wan','proto','dhcp');
					uci.set('network','wan','ifname','eth0.1 eth0.2');
					uci.set('wireless','@wifi-iface[0]','network','wan');
					uci.commit();
				}
			}
		return m.render();
	}
});
