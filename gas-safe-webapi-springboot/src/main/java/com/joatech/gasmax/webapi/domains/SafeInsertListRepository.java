package com.joatech.gasmax.webapi.domains;

import java.util.List;
import java.util.Map;

/*
 * 점검현황(FN점검현황 )
 * 
 * 안전 검침 현황
 * 2019.12.12 수정 - SAFE_CD, APP_User 추가
 */
public class SafeInsertListRepository extends GasMaxRepository {

	public SafeInsertListRepository(String dbHostname, int dbPortNumber, String dbName, String dbUsername,
			String dbPassword) {
		super(dbHostname, dbPortNumber, dbName, dbUsername, dbPassword);
		init();
	}
	
	public List<Map<String, Object>> findSafeInsertListBy(String areaCode, String findStr, String gumDateF, String gumDateT, String cuType, String cuCode,
			  String aptCd, String swCd, String manCd, String jyCd, String addrText, String suppYn, String conformityYn, String gpsX, String gpsY, String safeCd, String appUser) {

		String queryString = String.format("SELECT * FROM FN_SAFE_INSERT_LIST('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s')", areaCode, findStr, gumDateF, gumDateT, cuType,
			cuCode, aptCd, swCd, manCd, jyCd, addrText, suppYn, conformityYn, gpsX, gpsY, safeCd, appUser);
		List<Map<String, Object>> result = jdbcTemplate.queryForList(queryString);
		return result;
	}	
	
	public List<Map<String, Object>> findSafeInsertListByOrderBy(String areaCode, String findStr, String gumDateF, String gumDateT, String cuType, String cuCode,
													  String aptCd, String swCd, String manCd, String jyCd, String addrText, String suppYn, String conformityYn, 
													  String gpsX, String gpsY, String safeCd, String appUser, String orderBy) {

		String queryString = String.format("SELECT * FROM FN_SAFE_INSERT_LIST('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s') ORDER BY %s", areaCode, findStr, gumDateF, gumDateT, cuType,
											cuCode, aptCd, swCd, manCd, jyCd, addrText, suppYn, conformityYn, gpsX, gpsY, safeCd, appUser, orderBy);
		List<Map<String, Object>> result = jdbcTemplate.queryForList(queryString);
		return result;
	}

	public List<Map<String, Object>> findGpsSafeInsertListBy(String areaCode, String findStr, String gumDateF, String gumDateT, String cuType, String cuCode,
			  String aptCd, String swCd, String manCd, String jyCd, String addrText, String suppYn, String conformityYn, String gpsX, String gpsY, String safeCd, String appUser) {

		String queryString = String.format("SELECT * FROM FN_SAFE_INSERT_LIST_GPS('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s')", areaCode, findStr, gumDateF, gumDateT, cuType,
		cuCode, aptCd, swCd, manCd, jyCd, addrText, suppYn, conformityYn, gpsX, gpsY, safeCd, appUser);
		List<Map<String, Object>> result = jdbcTemplate.queryForList(queryString);
		return result;
	}
	
	public List<Map<String, Object>> findGpsSafeInsertListByOrderBy(String areaCode, String findStr, String gumDateF, String gumDateT, String cuType, String cuCode,
													  String aptCd, String swCd, String manCd, String jyCd, String addrText, String suppYn, String conformityYn, 
													  String gpsX, String gpsY, String safeCd, String appUser, String orderBy) {

		String queryString = String.format("SELECT * FROM FN_SAFE_INSERT_LIST_GPS('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s') ORDER BY %s", areaCode, findStr, gumDateF, gumDateT, cuType,
			cuCode, aptCd, swCd, manCd, jyCd, addrText, suppYn, conformityYn, gpsX, gpsY, safeCd, appUser, orderBy);
		List<Map<String, Object>> result = jdbcTemplate.queryForList(queryString);
		return result;
	}	
	
}
