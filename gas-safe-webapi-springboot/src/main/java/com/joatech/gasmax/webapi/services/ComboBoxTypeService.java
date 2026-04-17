package com.joatech.gasmax.webapi.services;

import java.util.List;
import java.util.Map;

import com.joatech.gasmax.webapi.domains.ComboBoxTypeRepository;

public class ComboBoxTypeService implements IComboBoxTypeService {

	private ComboBoxTypeRepository repo;
	
	public ComboBoxTypeService(String dbHostname, int dbPortNumber, String dbName, String dbUsername, String dbPassword) {
		repo = new ComboBoxTypeRepository(dbHostname, dbPortNumber, dbName, dbUsername, dbPassword);
	}
	
	public void close() {
		repo.close();
	}
	
	@Override
	public List<Map<String, Object>> getComboTypeListByTypeAndAreaCode(String type, String areaCode) {
		String orderBy = "GUBUN,CD";
		return repo.findAllByTypeAndAreaCodeOrderBy(type, areaCode, orderBy);
	}

	@Override
	public List<Map<String, Object>> getAllComboTypeListByAreaCode(String areaCode) {
		String type ="";
		String orderBy = "GUBUN,CD";
		return repo.findAllByTypeAndAreaCodeOrderBy(type, areaCode, orderBy);
	}

	@Override
	public List<Map<String, Object>> getAreaComboTypeList() {
		String type ="AREA";
		String areaCode = "";
		String orderBy = "GUBUN,CD";
		return repo.findAllByTypeAndAreaCodeOrderBy(type, areaCode, orderBy);
	}
}
