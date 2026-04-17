package com.joatech.gasmax.webapi.services;

import java.util.List;
import java.util.Map;

/*
 * 구분별 검색어 콤보박스 설정(FN 검색 정보 리스트)
 */
public interface IComboBoxSectionKeywordService {
	
	List<Map<String, Object>> getAllComboAptListByAreaCode(String areaCode);
	List<Map<String, Object>> getAllComboAptListByAreaCodeAndKeyword(String areaCode, String keyword);
	List<Map<String, Object>> getAllComboGumListByAreaCode(String areaCode);
	List<Map<String, Object>> getAllComboMeterListByAreaCode(String areaCode);

}
