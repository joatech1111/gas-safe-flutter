package com.joatech.gasmax.webapi.domains;

import java.io.Serializable;

import lombok.Data;

/*
 * 공급계약등록(SP_공급계약등록)
 */
@Data
public class AnCont {
    private static final long serialVersionUID = -6494208459892743747L;

    private String saveDiv = "";
    private String areaCode     = "";                       /* 영업소 코드       */
    private String anzCuCode    = "";                       /* 거래처 코드       */
    private String anzSno       = "";                       /* 시리얼 번호       */
    private String anzDate      = "";                       /* 계약일자          */
    private String anzDateF     = "";                       /* 계약시작          */
    private String anzDateT     = "";                       /* 계약종료          */
    private String saleType     = "";                       /* 구분    0:체적, 1: 중량    */
    private String contType     = "";                       /* 거래현황 0:신규, 2: 재계약  */
    private String useCyl       = "";                       /* 용기수량           */
    private String useCylMemo   = "";                       /* 용기비고           */
    private String useMeter     = "";                       /* 계량기수량          */
    private String useMeterMemo = "";                       /* 계량기비고          */
    private String useTrans     = "";                       /* 절체기수량          */
    private String useTransMemo = "";                       /* 철체기비고          */
    private String useVapor     = "";                       /* 기화기수량          */
    private String useVaporMemo = "";                       /* 기화기비고          */
    private String usePipe      = "";                       /* 공급관수량          */
    private String usePipeMemo  = "";                       /* 공급관비고          */
    private String useFacility  = "";                       /* 부속설비            */

    private String centerSi         = "";                   /* 시, 군, 구청        */
    private String centerConsumer   = "";                   /* 소비자단체          */
    private String centerKgs        = "";                   /* 가스안전공사         */

    private String centerGas        = "";                   /* 가스공급자 단체      */
    private String comBefore        = "";                   /* 종전공급자 상호      */
    private String comNo            = "";                   /* 공급사업자번호       */
    private String comName          = "";                   /* 상호               */
    private String comTel           = "";                   /* 전화               */
    private String comHp            = "";                   /* 긴급연락처          */
    private String comCeoName       = "";                   /* 대표자명            */
    private String comSignYn        = "";                   /* 서명유무            */

    private String cuGongno         = "";                   /* 공급계약번호         */
    private String custComNo        = "";                   /* 고객사업자번호       */
    private String custComName      = "";                   /* 고객상호            */
    private String cuAddr1          = "";                   /* 관할주소            */
    private String cuAddr2          = "";                   /* 상세주소            */
    private String custTel          = "";                   /* 고객전화            */
    private String cuGongName       = "";                   /* 계약자명            */
    private String custSign         = "";                   /* 고객서명유무         */
    private String contFileUrl      = "";                   /* PDF 다운로드        */
    private String anzCuConfirmTel  = "";                   /* */
    private String anzCuSmsYn       = "";                   /* */


    private String regDt            = "";                   /* 등록일자            */
    private String regUserId        = "";                   /* 등록ID             */
    private String regSwCode        = "";                   /* 사원코드            */
    private String regSwName        = "";                   /* 사원명              */
    private String userno           = "";                   /* 포탈상용자코드        */

    private String gpsX             = "";                   /*             */
    private String gpsY             = "";                   /*            */

    private String regDel           = "";                   /* 삭제유무           */
    private String regType          = "";                   /* 저장결로 ( A0:저장후sms, A1 : app저장, W0, W1: WEB 에서 저장  */


}
