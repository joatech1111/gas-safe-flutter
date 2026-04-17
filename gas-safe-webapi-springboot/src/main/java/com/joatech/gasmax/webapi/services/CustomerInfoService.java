package com.joatech.gasmax.webapi.services;

import java.util.Map;

import com.joatech.gasmax.webapi.domains.CustomerInfo;
import com.joatech.gasmax.webapi.domains.CustomerInfoRepository;

/*
 * 거래처 검색/정보
 */
public class CustomerInfoService implements ICustomerInfoService {

    private CustomerInfoRepository repo;

    public CustomerInfoService(String dbHostname, int dbPortNumber, String dbName, String dbUsername, String dbPassword) {
        repo = new CustomerInfoRepository(dbHostname, dbPortNumber, dbName, dbUsername, dbPassword);
    }

    public void close() {
        repo.close();
    }




    @Override
    public Map<String, Object> updateCustomerInfoService(CustomerInfo customerInfo) {

        return repo.executeCustomerEditSafe(
                customerInfo.getDiv(),
                customerInfo.getAreaCode(),
                customerInfo.getCuCode(),
                customerInfo.getCuType(),
                customerInfo.getCuName(),
                customerInfo.getCuUserName(),
                customerInfo.getCuTel(),
                customerInfo.getCuTelFind(),
                customerInfo.getCuHp(),
                customerInfo.getCuHpFind(),
                customerInfo.getZipCode(),
                customerInfo.getCuAddr1(),
                customerInfo.getCuAddr2(),
                customerInfo.getCuBigo1(),
                customerInfo.getCuBigo2(),
                customerInfo.getCuSwCode(),
                customerInfo.getCuSwName(),
                customerInfo.getCuCuType(),
                customerInfo.getGpsX(),
                customerInfo.getGpsY(),
                customerInfo.getAppUser());

    }

    /**
     * ✅ 거래처 단건 조회 (추가)
     */
    public CustomerInfo selectCustomerInfo(String areaCode, String cuCode) {
        return repo.selectCustomerInfo(areaCode, cuCode);
    }
}
