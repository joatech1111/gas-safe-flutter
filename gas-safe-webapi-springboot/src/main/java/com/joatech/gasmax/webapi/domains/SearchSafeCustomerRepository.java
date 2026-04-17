package com.joatech.gasmax.webapi.domains;

import java.util.List;
import java.util.Map;

/*
 * 점검 거래처 검색(FN_점검 검색어 검색)
 */
public class SearchSafeCustomerRepository extends GasMaxRepository {

	public SearchSafeCustomerRepository(String dbHostname, int dbPortNumber, String dbName, String dbUsername,
			String dbPassword) {
		super(dbHostname, dbPortNumber, dbName, dbUsername, dbPassword);
		init();
	}
	
	public List<Map<String, Object>> findSafeCustomerBy(String areaCode, String findStr, String safeFlan, String cuType, String cuCode, String aptCode, String swCd, String manCd, String jyCd, String addrText, String suppYN, String conformityYN, String gpsX, String gpsY) {
		String queryString = String.format("SELECT * FROM FN_SAFE_CU_FIND('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s')", 
				areaCode, findStr, safeFlan, cuType, cuCode, aptCode, swCd, manCd, jyCd, addrText, suppYN, conformityYN, gpsX, gpsY);
		List<Map<String, Object>> result = jdbcTemplate.queryForList(queryString);
		return result;
	}
	
	public List<Map<String, Object>> findSafeCustomerByOrderBy(String areaCode, String findStr, String safeFlan, String cuType, String cuCode, String aptCode, String swCd, String manCd, String jyCd, String addrText, String suppYN, String conformityYN, String gpsX, String gpsY, String orderBy) {
		String queryString = String.format("SELECT * FROM FN_SAFE_CU_FIND('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s') ORDER BY %s", 
				areaCode, findStr, safeFlan, cuType, cuCode, aptCode, swCd, manCd, jyCd, addrText, suppYN, conformityYN, gpsX, gpsY, orderBy);
		List<Map<String, Object>> result = jdbcTemplate.queryForList(queryString);
		return result;
	}
	
	public List<Map<String, Object>> findGpsSafeCustomerBy(String areaCode, String findStr, String safeFlan, String cuType, String cuCode, String aptCode, String swCd, String manCd, String jyCd, String addrText, String suppYN, String conformityYN, String gpsX, String gpsY) {
		String queryString = String.format("SELECT * FROM FN_SAFE_CU_FIND_GPS('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s')", 
				areaCode, findStr, safeFlan, cuType, cuCode, aptCode, swCd, manCd, jyCd, addrText, suppYN, conformityYN, gpsX, gpsY);
		List<Map<String, Object>> result = jdbcTemplate.queryForList(queryString);
		return result;
	}
	
	public List<Map<String, Object>> findGpsSafeCustomerByOrderBy(String areaCode, String findStr, String safeFlan, String cuType, String cuCode, String aptCode, String swCd, String manCd, String jyCd, String addrText, String suppYN, String conformityYN, String gpsX, String gpsY, String orderBy) {
		String queryString = String.format("SELECT * FROM FN_SAFE_CU_FIND_GPS('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s') ORDER BY %s", 
				areaCode, findStr, safeFlan, cuType, cuCode, aptCode, swCd, manCd, jyCd, addrText, suppYN, conformityYN, gpsX, gpsY, orderBy);
		List<Map<String, Object>> result = jdbcTemplate.queryForList(queryString);
		return result;
	}
	
}
