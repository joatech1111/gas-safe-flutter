package com.joatech.gasmax.webapi.domains;

import java.util.List;
import java.util.Map;

/*
 * 검침현환(FN 검침현황)*
 * 모바일 검침 현황
 * 2019.12.12 수정 - SAFE_CD, APP_User 추가
 */
public class MeterInsertRepository extends GasMaxRepository {

	public MeterInsertRepository(String dbHostname, int dbPortNumber, String dbName, String dbUsername,
			String dbPassword) {
		super(dbHostname, dbPortNumber, dbName, dbUsername, dbPassword);
		init();
	}
	
	
	public List<Map<String, Object>> findMeterInsertListBy(String areaCode, String findStr, String gumDateF, String gumDateT, String cuCode, String aptCd, String swCd, String manCd, 
															String jyCd, String addrText, String smartMeterYn, String gpsX, String gpsY, String safeCd, String appUser) {
		
		String queryString = String.format("SELECT * FROM FN_METER_INSERT_LIST('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s')", 
												areaCode, findStr, gumDateF, gumDateT, cuCode, aptCd, swCd, manCd, jyCd, addrText, smartMeterYn, gpsX, gpsY, safeCd, appUser);
		
		List<Map<String, Object>> result = jdbcTemplate.queryForList(queryString);

		return result;
	}

	public List<Map<String, Object>> findMeterInsertListByOrderBy(String areaCode, String findStr, String gumDateF, String gumDateT, String cuCode, String aptCd, String swCd, String manCd, 
			String jyCd, String addrText, String smartMeterYn, String gpsX, String gpsY, String safeCd, String appUser, String orderBy) {

		String queryString = String.format("SELECT * FROM FN_METER_INSERT_LIST('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s') ORDER BY %s", 
				areaCode, findStr, gumDateF, gumDateT, cuCode, aptCd, swCd, manCd, jyCd, addrText, smartMeterYn, gpsX, gpsY, safeCd, appUser, orderBy);

		List<Map<String, Object>> result = jdbcTemplate.queryForList(queryString);

		return result;
	}
	
	public List<Map<String, Object>> findGpsMeterInsertListBy(String areaCode, String findStr, String gumDateF, String gumDateT, String cuCode, String aptCd, String swCd, String manCd, 
			String jyCd, String addrText, String smartMeterYn, String gpsX, String gpsY, String safeCd, String appUser) {

		String queryString = String.format("SELECT * FROM FN_METER_INSERT_LIST_GPS('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s')", 
				areaCode, findStr, gumDateF, gumDateT, cuCode, aptCd, swCd, manCd, jyCd, addrText, smartMeterYn, gpsX, gpsY, safeCd, appUser);
		List<Map<String, Object>> result = jdbcTemplate.queryForList(queryString);
		return result;
	}
	
	public List<Map<String, Object>> findGpsMeterInsertListByOrderBy(String areaCode, String findStr, String gumDateF, String gumDateT, String cuCode, String aptCd, String swCd, String manCd, 
			String jyCd, String addrText, String smartMeterYn, String gpsX, String gpsY, String safeCd, String appUser, String orderBy) {

		String queryString = String.format("SELECT * FROM FN_METER_INSERT_LIST_GPS('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s') ORDER BY %s", 
				areaCode, findStr, gumDateF, gumDateT, cuCode, aptCd, swCd, manCd, jyCd, addrText, smartMeterYn, gpsX, gpsY, safeCd, appUser, orderBy);

		List<Map<String, Object>> result = jdbcTemplate.queryForList(queryString);
		return result;
	}

}
