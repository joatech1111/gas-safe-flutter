package com.joatech.gasmax.webapi.domains;

import java.util.List;
import java.util.Map;

/*
 * 구분별 검색어 콤보박스 설정(FN 검색 정보 리스트)
 */
public class ComboBoxSectionKeywordRepository extends GasMaxRepository{

	public ComboBoxSectionKeywordRepository(String dbHostname, int dbPortNumber, String dbName, String dbUsername,
			String dbPassword) {
		super(dbHostname, dbPortNumber, dbName, dbUsername, dbPassword);
		init();
	}
	
	public List<Map<String, Object>> findAptComboOrderBy(String areaCode, String findKey, String orderBy) {
		
		String queryString = String.format("SELECT * FROM FN_COMBO_APT_FIND('%s', '%s') ORDER BY %s", areaCode, findKey, orderBy);
		List<Map<String, Object>> result = jdbcTemplate.queryForList(queryString);
		return result;
	}
	
	public List<Map<String, Object>> findGumComboOrderBy(String areaCode, String findKey, String orderBy) {
		String queryString = String.format("SELECT * FROM FN_COMBO_GUM_FIND('%s', '%s') ORDER BY %s", areaCode, findKey, orderBy);
		List<Map<String, Object>> result = jdbcTemplate.queryForList(queryString);
		return result;
	}
	
	public List<Map<String, Object>> findMeterComboOrderBy(String areaCode, String findKey, String orderBy) {
		String queryString = String.format("SELECT * FROM FN_COMBO_METER_FIND('%s', '%s') ORDER BY %s", areaCode, findKey, orderBy);
		List<Map<String, Object>> result = jdbcTemplate.queryForList(queryString);
		return result;
	}
}
