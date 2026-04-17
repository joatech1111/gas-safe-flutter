package com.joatech.gasmax.webapi.services;

import java.util.List;
import java.util.Map;
import com.joatech.gasmax.webapi.domains.ComboBoxSectionKeywordRepository;

/*
 * 구분별 검색어 콤보박스 설정(FN 검색 정보 리스트)
 */
public class ComboBoxSectionKeywordService implements IComboBoxSectionKeywordService {
	
	private ComboBoxSectionKeywordRepository repo;
	
	public ComboBoxSectionKeywordService(String dbHostname, int dbPortNumber, String dbName, String dbUsername, String dbPassword) {
		repo = new ComboBoxSectionKeywordRepository(dbHostname, dbPortNumber, dbName, dbUsername, dbPassword);
	}
	
	public void close() {
		repo.close();
	}
	

	@Override
	public List<Map<String, Object>> getAllComboAptListByAreaCode(String areaCode) {
		
		String findKey = "";
		String orderBy = "CD_Name, CD";
		
		return repo.findAptComboOrderBy(areaCode, findKey, orderBy);
		
	}

	@Override
	public List<Map<String, Object>> getAllComboAptListByAreaCodeAndKeyword(String areaCode, String keyword) {
		
		String orderBy = "CD_Name, CD";
		
		return repo.findAptComboOrderBy(areaCode, keyword, orderBy);
	}

	@Override
	public List<Map<String, Object>> getAllComboGumListByAreaCode(String areaCode) {
		
		String findKey = "";
		String orderBy = "CD_Name, CD";
		
		return repo.findGumComboOrderBy(areaCode, findKey, orderBy);
	}

	@Override
	public List<Map<String, Object>> getAllComboMeterListByAreaCode(String areaCode) {
		
		String findKey = "";
		String orderBy = "CD_Name, CD";
		return repo.findMeterComboOrderBy(areaCode, findKey, orderBy);
	}

}
