package com.joatech.gasmax.webapi.domains;

import java.util.Map;

/*
 * SMS 점검 안내문
 */
public class SMSNoticesRepository extends GasMaxRepository {

	public SMSNoticesRepository(String dbHostname, int dbPortNumber, String dbName, String dbUsername,
			String dbPassword) {
		super(dbHostname, dbPortNumber, dbName, dbUsername, dbPassword);
		init();
	}

	public Map<String, Object> findSmsNoticesSafeBy(String areaCode) {
		String queryString = String.format("SELECT * FROM FN_SAFE_SMS_MSG('%s')", areaCode);
		Map<String, Object> result = jdbcTemplate.queryForMap(queryString);
		return result;
	}
	
	public Map<String, Object> findSmsNoticesSafeSmsDivBy(String areaCode, String smsDiv) {
		String queryString = String.format("SELECT * FROM fn_SAFE_SMS_MSG_2('%s', '%s')", areaCode, smsDiv);
		Map<String, Object> result = jdbcTemplate.queryForMap(queryString);
		return result;
	}
}
