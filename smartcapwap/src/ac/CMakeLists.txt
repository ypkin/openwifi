cmake_minimum_required (VERSION 2.6)

project(smartcapwap C)

add_definitions(-D_GNU_SOURCE -DHAVE_CONFIG_H)
add_definitions(-DCAPWAP_MULTITHREADING_ENABLE)

if(NOT OPENWRT)
	add_definitions(-I/usr/include/libxml2 -I/usr/include/libnl3)
endif()

include_directories(${CMAKE_SOURCE_DIR})
include_directories(${CMAKE_SOURCE_DIR}/../common)
include_directories(${CMAKE_SOURCE_DIR}/../common/binding/ieee80211)
include_directories(${CMAKE_SOURCE_DIR}/../kmod)

SET(AC_SOURCES
	${CMAKE_SOURCE_DIR}/../common/capwap.c
	${CMAKE_SOURCE_DIR}/../common/capwap_event.c 
	${CMAKE_SOURCE_DIR}/../common/capwap_lock.c 
	${CMAKE_SOURCE_DIR}/../common/capwap_rwlock.c
	${CMAKE_SOURCE_DIR}/../common/capwap_socket.c
	${CMAKE_SOURCE_DIR}/../common/capwap_logging.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element.c
	${CMAKE_SOURCE_DIR}/../common/capwap_protocol.c
	${CMAKE_SOURCE_DIR}/../common/capwap_timeout.c
	${CMAKE_SOURCE_DIR}/../common/capwap_array.c
	${CMAKE_SOURCE_DIR}/../common/capwap_list.c
	${CMAKE_SOURCE_DIR}/../common/capwap_network.c
	${CMAKE_SOURCE_DIR}/../common/capwap_dtls.c
	${CMAKE_SOURCE_DIR}/../common/capwap_hash.c
	${CMAKE_SOURCE_DIR}/../common/binding/ieee80211/ieee80211.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_acname.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_wtpframetunnelmode.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_statisticstimer.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_wtpboarddata.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_transport.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_wtpradiostat.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_wtpdescriptor.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_wtpname.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_ecnsupport.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_80211_stationqos.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_initdownload.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_mtudiscovery.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_sessionid.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_localipv4.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_localipv6.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_wtpstaticipaddress.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_wtpmactype.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_location.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_wtprebootstat.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_wtpfallback.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_radiooprstate.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_maximumlength.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_vendorpayload.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_duplicateipv4.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_duplicateipv6.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_discoverytype.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_imagedata.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_deletestation.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_idletimeout.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_resultcode.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_controlipv4.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_controlipv6.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_acipv4list.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_acipv6list.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_deletemacacl.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_imageinfo.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_timers.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_vendor_travelping_wtp_timestamp.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_vendor_travelping_80211_encryption_capability.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_vendor_travelping_80211_update_key.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_80211_wtpradioinformation.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_80211_wtpradiofailalarm.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_80211_addwlan.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_80211_antenna.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_80211_assignbssid.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_80211_deletewlan.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_80211_ie.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_80211_macoperation.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_80211_miccountermeasures.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_80211_multidomaincapability.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_80211_ofdmcontrol.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_80211_rateset.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_80211_stationkey.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_80211_stationqos.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_80211_supportedrates.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_80211_wtpqos.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_80211_txpower.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_80211_txpowerlevel.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_80211_updatestationqos.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_80211_updatewlan.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_80211_directsequencecontrol.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_80211_rsnaerrorreport.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_80211_wtpradioconf.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_80211_station.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_80211_statistics.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_actimestamp.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_acdescriptor.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_acnamepriority.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_addmacacl.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_addstation.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_datatransferdata.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_datatransfermode.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_decrypterrorreport.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_decrypterrorreportperiod.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_imageidentifier.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_radioadmstate.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_returnedmessage.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_80211n_station_information.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_80211n_radioconf.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_80211_supported_mac_profiles.c
	${CMAKE_SOURCE_DIR}/../common/capwap_element_80211_mac_profile.c
	${CMAKE_SOURCE_DIR}/ac.c
	${CMAKE_SOURCE_DIR}/ac_backend.c
	${CMAKE_SOURCE_DIR}/ac_execute.c
	${CMAKE_SOURCE_DIR}/ac_session.c
	${CMAKE_SOURCE_DIR}/ac_wlans.c
	${CMAKE_SOURCE_DIR}/ac_kmod.c
	${CMAKE_SOURCE_DIR}/ac_ieee80211_data.c
	${CMAKE_SOURCE_DIR}/ac_discovery.c
	${CMAKE_SOURCE_DIR}/ac_80211_json.c
	${CMAKE_SOURCE_DIR}/ac_80211_json_addwlan.c
	${CMAKE_SOURCE_DIR}/ac_80211_json_antenna.c
	${CMAKE_SOURCE_DIR}/ac_80211_json_assignbssid.c
	${CMAKE_SOURCE_DIR}/ac_80211_json_deletewlan.c
	${CMAKE_SOURCE_DIR}/ac_80211_json_directsequencecontrol.c
	${CMAKE_SOURCE_DIR}/ac_80211_json_ie.c
	${CMAKE_SOURCE_DIR}/ac_80211_json_macoperation.c
	${CMAKE_SOURCE_DIR}/ac_80211_json_miccountermeasures.c
	${CMAKE_SOURCE_DIR}/ac_80211_json_multidomaincapability.c
	${CMAKE_SOURCE_DIR}/ac_80211_json_ofdmcontrol.c
	${CMAKE_SOURCE_DIR}/ac_80211_json_rateset.c
	${CMAKE_SOURCE_DIR}/ac_80211_json_rsnaerrorreport.c
	${CMAKE_SOURCE_DIR}/ac_80211_json_statistics.c
	${CMAKE_SOURCE_DIR}/ac_80211_json_supportedrates.c
	${CMAKE_SOURCE_DIR}/ac_80211_json_txpower.c
	${CMAKE_SOURCE_DIR}/ac_80211_json_txpowerlevel.c
	${CMAKE_SOURCE_DIR}/ac_80211_json_updatewlan.c
	${CMAKE_SOURCE_DIR}/ac_80211_json_wtpqos.c
	${CMAKE_SOURCE_DIR}/ac_80211_json_wtpradioconf.c
	${CMAKE_SOURCE_DIR}/ac_80211_json_wtpradiofailalarm.c
	${CMAKE_SOURCE_DIR}/ac_80211_json_wtpradioinformation.c
	${CMAKE_SOURCE_DIR}/ac_dfa_join.c
	${CMAKE_SOURCE_DIR}/ac_dfa_configure.c
	${CMAKE_SOURCE_DIR}/ac_dfa_imagedata.c
	${CMAKE_SOURCE_DIR}/ac_dfa_datacheck.c
	${CMAKE_SOURCE_DIR}/ac_dfa_dtls.c
	${CMAKE_SOURCE_DIR}/ac_dfa_run.c
	${CMAKE_SOURCE_DIR}/ac_dfa_reset.c
	${CMAKE_SOURCE_DIR}/ac_dfa_teardown.c
	${CMAKE_SOURCE_DIR}/ac_soap.c)

add_executable(ac ${AC_SOURCES})

target_link_libraries(ac wolfssl json-c xml2 config pthread ev)

if(OPENWRT)
	target_link_libraries(ac nl-tiny)
else()
	target_link_libraries(ac nl-3 nl-genl-3)
endif()

install(TARGETS ac
	ARCHIVE DESTINATION lib
	LIBRARY DESTINATION lib
	RUNTIME DESTINATION bin
)