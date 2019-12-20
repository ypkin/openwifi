'use strict';
'require fs';
'require ui';
'require uci';
'require form';
'require network';
'require tools.widgets as widgets';

return L.view.extend({

	render: function() {
		var m, s, sw;

		m = new form.Map('wifimedia');

		s = m.section(form.TypedSection, 'switchmode', _('Switch Mode'));
		s.anonymous = true;
		s.addremove = true;
	
		sw = s.option(form.Flag,"switch_port","All Port LAN & WAN")
		sw.rmempty = false
		sw.write = sw.remove = function(section_id, value) {
			if(value != null ){
				
			}			
		}
		return m.render();
	}
});
