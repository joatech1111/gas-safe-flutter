package com.joatech.gasmax.webapi.services;

import java.util.List;
import java.util.Map;
import com.joatech.gasmax.webapi.domains.AnCont;



public interface IAnContService {
    Map<String, Object> createAnCont(AnCont anCont);
    Map<String, Object> updateAnCont(AnCont anCont);
    Map<String, Object> deleteAnCont(AnCont anCont);
    List<Map<String, Object>> getAnContServiceBy(String areaCode, String anzCuCode, String anzSno);
    List<Map<String, Object>> getLastAnContServiceBy(String areaCode, String anzCuCode);

}
