package com.joatech.gasmax.webapi.domains;

import java.util.List;
import java.util.Map;

/*
 * 구분별 콤보박스 설정(FN 콤보 List)
 */
public class ComboBoxTypeRepository extends GasMaxRepository {

	public ComboBoxTypeRepository(String dbHostname, int dbPortNumber, String dbName, String dbUsername, String dbPassword) {
		super(dbHostname, dbPortNumber, dbName, dbUsername, dbPassword);
		init();
	}

	public List<Map<String, Object>> findAllByTypeAndAreaCode(String type, String areaCode) {
		String queryString = String.format("SELECT * FROM FN_Combo_GUBUN_LIST('%s', '%s')", type, areaCode);
		List<Map<String, Object>> result = jdbcTemplate.queryForList(queryString);
		return result;
	}

	public List<Map<String, Object>> findAllByTypeAndAreaCodeOrderBy(String type, String areaCode, String orderBy) {
		String queryString = String.format("SELECT * FROM FN_Combo_GUBUN_LIST('%s', '%s') ORDER BY %s", type, areaCode, orderBy);
		List<Map<String, Object>> result = jdbcTemplate.queryForList(queryString);
		return result;
	}

}
