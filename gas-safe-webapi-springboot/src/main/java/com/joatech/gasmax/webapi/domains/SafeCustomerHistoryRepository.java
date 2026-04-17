package com.joatech.gasmax.webapi.domains;

import java.util.List;
import java.util.Map;

/*
 * 안전점검 현황(거래처 점검 이력)
 */
public class SafeCustomerHistoryRepository extends GasMaxRepository {

	public SafeCustomerHistoryRepository(String dbHostname, int dbPortNumber, String dbName, String dbUsername,
			String dbPassword) {
		super(dbHostname, dbPortNumber, dbName, dbUsername, dbPassword);
		init();
	}

	public List<Map<String, Object>> findSafeCustomerHistoryByOrderBy(String areaCode, String cuCode, String shDate, String orderBy) {

		String queryString = String.format("SELECT * FROM FN_SAFE_CU_HISTORY_V2('%s', '%s', '%s') ORDER BY %s", areaCode, cuCode, shDate, orderBy);
		List<Map<String, Object>> result = jdbcTemplate.queryForList(queryString);
		return result;
	}
	
}
