package com.joatech.gasmax.webapi.services;

import java.util.List;
import java.util.Map;

public interface IComboBoxTypeService {
	List<Map<String, Object>> getComboTypeListByTypeAndAreaCode(String type, String areaCode);
	List<Map<String, Object>> getAllComboTypeListByAreaCode(String areaCode);
	List<Map<String, Object>> getAreaComboTypeList();
}
