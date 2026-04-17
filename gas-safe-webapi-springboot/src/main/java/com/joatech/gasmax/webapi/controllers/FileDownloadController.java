package com.joatech.gasmax.webapi.controllers;

//import com.lowagie.text.PageSize;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.beans.Expression;
import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.Files;
import java.nio.charset.StandardCharsets;

import java.io.*;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.util.Base64;
import java.util.regex.Matcher;

import org.springframework.stereotype.Component;

import com.itextpdf.text.Document;
import com.itextpdf.text.DocumentException;
import com.itextpdf.text.Image;
import com.itextpdf.text.PageSize;
import com.itextpdf.text.pdf.PdfWriter;
import com.itextpdf.tool.xml.XMLWorker;
import com.itextpdf.tool.xml.XMLWorkerFontProvider;
import com.itextpdf.tool.xml.XMLWorkerHelper;
import com.itextpdf.tool.xml.css.CssFile;
import com.itextpdf.tool.xml.css.StyleAttrCSSResolver;
import com.itextpdf.tool.xml.html.CssAppliers;
import com.itextpdf.tool.xml.html.CssAppliersImpl;
import com.itextpdf.tool.xml.html.Tags;
import com.itextpdf.tool.xml.parser.XMLParser;
import com.itextpdf.tool.xml.pipeline.css.CSSResolver;
import com.itextpdf.tool.xml.pipeline.css.CssResolverPipeline;
import com.itextpdf.tool.xml.pipeline.end.PdfWriterPipeline;
import com.itextpdf.tool.xml.pipeline.html.AbstractImageProvider;
import com.itextpdf.tool.xml.pipeline.html.HtmlPipeline;
import com.itextpdf.tool.xml.pipeline.html.HtmlPipelineContext;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import com.joatech.gasmax.webapi.domains.AnCont;
import com.joatech.gasmax.webapi.services.AnContService;

import java.util.Map;
import java.util.HashMap;

@RestController
public class FileDownloadController {
    // 파일이 저장된 디렉토리 경로 (예시)
//    private final Path pdfFolder = Paths.get("D:\\0.안전관리\\gasmax\\gasmax\\gasmax-web-api\\cont_doc");
//    private final Path pdfFolder1 = Paths.get("D:\\0.안전관리\\gasmax\\gasmax\\gasmax-web-api\\AnCont_pdf");
    private final Path pdfFolder = Paths.get(System.getProperty("user.dir"), "cont_doc");
    private final Path pdfFolder1 = Paths.get(System.getProperty("user.dir"), "AnCont_pdf");

    @Value("${gas-max.download-base-url:http://gas.joaoffice.com:14013}")
    private String downloadBaseUrl;

    /**
     * 클라이언트에서 생성한 PDF 파일 업로드
     * POST /upload/contract-pdf?filename=xxx
     */
    @PostMapping("/upload/contract-pdf")
    public ResponseEntity<Map<String, String>> uploadContractPdf(
            @RequestParam("file") MultipartFile file,
            @RequestParam("filename") String filename) {
        try {
            // 파일명 정리 (.pdf 확장자 보장)
            String safeName = filename.replaceAll("[^a-zA-Z0-9_\\-]", "");
            if (safeName.isEmpty()) safeName = "contract_" + System.currentTimeMillis();
            String pdfFilename = safeName + ".pdf";

            // AnCont_pdf 디렉토리에 저장
            Path target = pdfFolder1.resolve(pdfFilename).normalize();
            Files.createDirectories(target.getParent());
            file.transferTo(target.toFile());

            // 다운로드 URL 생성
            String downloadUrl = downloadBaseUrl + "/download/" + pdfFilename;

            Map<String, String> result = new HashMap<>();
            result.put("url", downloadUrl);
            result.put("filename", pdfFilename);
            System.out.println("[UPLOAD] PDF saved: " + target + " -> " + downloadUrl);
            return ResponseEntity.ok(result);
        } catch (IOException e) {
            e.printStackTrace();
            Map<String, String> error = new HashMap<>();
            error.put("error", "파일 저장 실패: " + e.getMessage());
            return ResponseEntity.status(500).body(error);
        }
    }

    @GetMapping("/download/{filename}")
    public ResponseEntity<Resource> downloadFile(@PathVariable String filename) throws IOException {
        // 파일 경로 생성
        Path filePath = pdfFolder1.resolve(filename).normalize();
        Resource resource = new UrlResource(filePath.toUri());

        // github 테스틓 확인
        // 파일이 존재하지 않으면 404 반환
        if (!resource.exists()) {
            return ResponseEntity.notFound().build();
        }

        // 파일을 다운로드할 수 있도록 헤더 설정
        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_PDF)  // PDF 파일 타입 설정
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + resource.getFilename() + "\"")
                .body(resource);
    }

    @GetMapping("/download1/{filename}")
    public ResponseEntity<Resource> downloadFile1(@PathVariable String filename) throws IOException {
        // 파일 경로 생성
        Path filePath = pdfFolder.resolve(filename).normalize();
        Resource resource = new UrlResource(filePath.toUri());

        // github 테스틓 확인
        // 파일이 존재하지 않으면 404 반환
        if (!resource.exists()) {
            return ResponseEntity.notFound().build();
        }

        // 파일을 다운로드할 수 있도록 헤더 설정
        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_PDF)  // PDF 파일 타입 설정
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + resource.getFilename() + "\"")
                .body(resource);
    }

    @GetMapping("/createfile2/{filename}")
    public  String AnCont_Create2(@PathVariable String filename) throws IOException{

        Path AnContfile =  pdfFolder.resolve(filename).normalize();
        Path AnContfilepdf =  pdfFolder1.resolve(filename).normalize();
        //Resource resource = new UrlResource(AnContfile.toUri());

        String filePath = AnContfile + ".html";
        String filePathPdf = AnContfilepdf + ".pdf";

        // HTML 콘텐츠 생성
        String htmlContent = "<!DOCTYPE html>\n"
                + "<html lang=\"ko\">\n"
                + "<head>\n"
                + "     <meta charset=\"UTF-8\">\n"
                + "</head>\n"
                + "<body>\n"
                + "    <h1>안녕하세요. 조아테크 입니다.2</h1>\n"
                + "    <p>This is a simple HTML page generated by Java.</p>\n"
                + "</body>\n"
                + "</html>";

        //String htmlContent1 = AnContfile();

        // HTML 파일 생성 및 작성
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(new File(filePath)))) {
            writer.write(htmlContent);
            System.out.println("HTML 파일이 생성되었습니다: " + filePath);

        } catch (IOException e) {
            e.printStackTrace();
        }

        //try {
            // HTML 파일을 PDF로 변환
        //    HtmlConverter.convertToPdf(new FileInputStream(new File(filePath)),
        //            new FileOutputStream(new File(filePathPdf)));
        //    System.out.println("PDF 파일로 변환 완료!");
        //} catch (IOException e) {
        //    e.printStackTrace();
        //    System.out.println("HTML을 PDF로 변환하는 도중 오류가 발생했습니다.");
        //}



        return "HTML 파일이 생성되었습니다: " + filePath  + "/" + filePathPdf;

    }



    @GetMapping("/createfile/{filename}")
    public  String AnCont_Create(@PathVariable String filename) throws IOException{

        Path AnContfile =  pdfFolder.resolve(filename).normalize();
        Path AnContfilepdf =  pdfFolder1.resolve(filename).normalize();
        //Resource resource = new UrlResource(AnContfile.toUri());

        String filePath = AnContfile + ".html";
        String filePathPdf = AnContfilepdf + ".pdf";

        String htmlContent = AnContfileTest();

        // HTML 파일 생성 및 작성
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(new File(filePath)))) {
            writer.write(htmlContent);
            System.out.println("HTML 파일이 생성되었습니다: " + filePath);

        } catch (IOException e) {
            e.printStackTrace();
        }

        createPDFTest(filename);

        return "HTML 파일이 생성되었습니다: " + filePath  + "/" + filePathPdf;

    }

    public void createPDF(String filename, AnCont ContData) {
        createPDF(filename, ContData, "", "");
    }

    public void createPDF(String filename, AnCont ContData, String customerSign, String supplierSign) {

        // 최초 문서 사이즈 설정
        Document document = new Document(PageSize.B4, 20, 20, 0, 0);

        Path AnContfilepdf =  pdfFolder1.resolve(filename).normalize();
        String filePathPdf = AnContfilepdf + ".pdf";

        try {

            // PDF 파일 생성
            PdfWriter pdfWriter = PdfWriter.getInstance(document, new FileOutputStream(filePathPdf));
            // PDF 파일에 사용할 폰트 크기 설정
            pdfWriter.setInitialLeading(10.5f);
            // PDF 파일 열기
            document.open();

            // XMLWorkerHelper xmlWorkerHelper = XMLWorkerHelper.getInstance();
            // CSS 설정 변수 세팅
            CSSResolver cssResolver = new StyleAttrCSSResolver();
            CssFile cssFile = null;

            try {
                /*
                 * CSS 파일 설정
                 * 기존 방식은 FileInputStream을 사용했으나, jar 파일로 빌드 시 파일을 찾을 수 없는 문제가 발생
                 * 따라서, ClassLoader를 사용하여 파일을 읽어오는 방식으로 변경
                 */
                InputStream cssStream = getClass().getClassLoader().getResourceAsStream("static/css/Pdf.css");

                // CSS 파일 담기
                cssFile = XMLWorkerHelper.getCSS(cssStream);
//                cssFile = XMLWorkerHelper.getCSS(new FileInputStream("src/main/resources/static/css/test.css"));
            } catch (Exception e) {
                throw new IllegalArgumentException("PDF CSS 파일을 찾을 수 없습니다.");
            }

            if(cssFile == null) {
                throw new IllegalArgumentException("PDF CSS 파일을 찾을 수 없습니다.");
            }

            // CSS 파일 적용
            cssResolver.addCss(cssFile);

            // PDF 파일에 HTML 내용 삽입
            XMLWorkerFontProvider fontProvider = new XMLWorkerFontProvider(XMLWorkerFontProvider.DONTLOOKFORFONTS);

            /*
             * 폰트 설정
             * CSS 와 다르게, fontProvider.register() 메소드를 사용하여 폰트를 등록해야 함
             * 해당 메소드 내부에서 경로처리를 하여 개발, 배포 시 폰트 파일을 찾을 수 있도록 함
             * */
            try {
                //fontProvider.register("static/font/NotoSansKR-Regular.woff", "NotoSansKR");
                fontProvider.register("static/font/AppleSDGothicNeoR.ttf", "AppleSDGothicNeo");
            } catch (Exception e) {
                throw new IllegalArgumentException("PDF 폰트 파일을 찾을 수 없습니다.");
            }

            if(fontProvider.getRegisteredFonts() == null) {
                throw new IllegalArgumentException("PDF 폰트 파일을 찾을 수 없습니다.");
            }

            // 사용할 폰트를 담아두었던 내용을
            // CSSAppliersImpl에 담아 적용
            CssAppliers cssAppliers = new CssAppliersImpl(fontProvider);

            // HTML Pipeline 생성
            HtmlPipelineContext htmlPipelineContext = new HtmlPipelineContext(cssAppliers);
            htmlPipelineContext.setTagFactory(Tags.getHtmlTagProcessorFactory());
            // 서명 이미지 로드를 위한 ImageProvider 설정
            htmlPipelineContext.setImageProvider(new AbstractImageProvider() {
                @Override
                public String getImageRootPath() {
                    return pdfFolder1.toAbsolutePath().toString() + File.separator;
                }
                @Override
                public Image retrieve(String src) {
                    try {
                        // file:// URI → 파일 경로 변환
                        String path = src;
                        if (src.startsWith("file:")) {
                            path = new java.net.URI(src).getPath();
                        }
                        File imgFile = new File(path);
                        if (!imgFile.isAbsolute()) {
                            imgFile = new File(getImageRootPath(), path);
                        }
                        if (imgFile.exists()) {
                            System.out.println("[SIGN] ImageProvider loading: " + imgFile.getAbsolutePath());
                            Image img = Image.getInstance(imgFile.getAbsolutePath());
                            store(src, img);
                            return img;
                        }
                        System.out.println("[SIGN] ImageProvider file NOT found: " + imgFile.getAbsolutePath());
                    } catch (Exception e) {
                        System.out.println("[SIGN] ImageProvider error: " + e.getMessage());
                        e.printStackTrace();
                    }
                    return null;
                }
            });

            // ========================================================================================
            // Pipelines
            PdfWriterPipeline pdfWriterPipeline = new PdfWriterPipeline(document, pdfWriter);
            HtmlPipeline htmlPipeline = new HtmlPipeline(htmlPipelineContext, pdfWriterPipeline);
            CssResolverPipeline cssResolverPipeline = new CssResolverPipeline(cssResolver, htmlPipeline);
            // ========================================================================================


            // ========================================================================================
            // XMLWorker
            XMLWorker xmlWorker = new XMLWorker(cssResolverPipeline, true);
            XMLParser xmlParser = new XMLParser(true, xmlWorker, StandardCharsets.UTF_8);
            // ========================================================================================


            /* HTML 내용을 담은 String 변수
            주의점
            1. HTML 태그는 반드시 닫아야 함
            2. xml 기준 html 태그 확인( ex : <p> </p> , <img/> , <col/> )
            위 조건을 지키지 않을 경우 DocumentException 발생
            */
            String htmlStr = toXmlWorkerSafeHtml(buildTwoPageContractHtml(filename, ContData, customerSign, supplierSign));

            // HTML 내용을 PDF 파일에 삽입
            StringReader stringReader = new StringReader(htmlStr);
            // XML 파싱
            xmlParser.parse(stringReader);
            // PDF 문서 닫기
            document.close();
            // PDF Writer 닫기
            pdfWriter.close();


        } catch (DocumentException e1) {
            throw new IllegalArgumentException("PDF 라이브러리 설정 에러");
        } catch (FileNotFoundException e2) {
            e2.printStackTrace();
            throw new IllegalArgumentException("PDF 파일 생성중 에러");
        } catch (IOException e3) {
            e3.printStackTrace();
            throw new IllegalArgumentException("PDF 파일 생성중 에러2");
        } catch (Exception e4) {
            e4.printStackTrace();
            throw new IllegalArgumentException("PDF 파일 생성중 에러3");
        }
        finally {
            try {
                document.close();
            } catch (Exception e) {
                System.out.println("PDF 파일 닫기 에러");
                e.printStackTrace();
            }
        }

    }

    private String buildTwoPageContractHtml(String filename, AnCont contData, String customerSign, String supplierSign) {
        // Keep production generation aligned with the long-form template that was
        // previously used for stable two-page output.
        String html = AnContfileTest();
        return injectSignatureImages(filename, html, customerSign, supplierSign);
    }

    private String injectSignatureImages(String filename, String html, String customerSign, String supplierSign) {
        if (html == null || html.isEmpty()) return html;
        String output = html;

        System.out.println("[SIGN] injectSignatureImages called - supplier:" + (supplierSign != null ? supplierSign.length() : 0) + " customer:" + (customerSign != null ? customerSign.length() : 0));

        String supplierImg = toSignatureImgTag(filename, "supplier", supplierSign);
        String customerImg = toSignatureImgTag(filename, "customer", customerSign);

        System.out.println("[SIGN] supplierImg tag: " + (supplierImg.isEmpty() ? "(empty)" : supplierImg.substring(0, Math.min(80, supplierImg.length()))));
        System.out.println("[SIGN] customerImg tag: " + (customerImg.isEmpty() ? "(empty)" : customerImg.substring(0, Math.min(80, customerImg.length()))));

        // HTML에서 서명 placeholder 위치 디버깅
        int idx서명 = output.indexOf("서명");
        System.out.println("[SIGN] indexOf '서명' = " + idx서명);
        if (idx서명 > -1) {
            int start = Math.max(0, idx서명 - 5);
            int end = Math.min(output.length(), idx서명 + 30);
            String snippet = output.substring(start, end);
            System.out.println("[SIGN] context around first '서명': [" + snippet + "]");
            // hex dump for invisible chars
            StringBuilder hex = new StringBuilder();
            for (char c : snippet.toCharArray()) {
                hex.append(String.format("%04x ", (int) c));
            }
            System.out.println("[SIGN] hex: " + hex);
        }

        // 다양한 패턴 시도
        String signPlaceholderRegex = "\\(서명(?:\\s|&nbsp;|\\u00a0)*또는(?:\\s|&nbsp;|\\u00a0)*인\\)";

        boolean hasPlaceholder = java.util.regex.Pattern.compile(signPlaceholderRegex).matcher(output).find();
        System.out.println("[SIGN] HTML contains signature placeholder: " + hasPlaceholder);

        if (!supplierImg.isEmpty()) {
            output = output.replaceFirst(signPlaceholderRegex, Matcher.quoteReplacement(supplierImg));
        }
        if (!customerImg.isEmpty()) {
            output = output.replaceFirst(signPlaceholderRegex, Matcher.quoteReplacement(customerImg));
        }
        return output;
    }

    private String toSignatureImgTag(String filename, String role, String signRaw) {
        String src = resolveSignatureImageSource(filename, role, signRaw);
        if (src.isEmpty()) return "";
        return "<img src=\"" + src + "\" width=\"120\" height=\"48\" />";
    }

    private String resolveSignatureImageSource(String filename, String role, String signRaw) {
        if (signRaw == null) return "";
        String sign = signRaw.trim();
        if (sign.isEmpty()) return "";

        if (sign.startsWith("http://") || sign.startsWith("https://") || sign.startsWith("file:")) {
            return sign;
        }
        if (sign.startsWith("/") || sign.startsWith("./")) {
            return Paths.get(sign).toAbsolutePath().normalize().toUri().toString();
        }

        String ext = "png";
        String payload = sign;
        if (sign.startsWith("data:image")) {
            int slashIndex = sign.indexOf('/');
            int semicolonIndex = sign.indexOf(';');
            int base64MarkerIndex = sign.indexOf("base64,");
            if (slashIndex > -1 && semicolonIndex > slashIndex) {
                ext = sign.substring(slashIndex + 1, semicolonIndex).toLowerCase();
                if ("jpeg".equals(ext)) ext = "jpg";
            }
            if (base64MarkerIndex > -1) {
                payload = sign.substring(base64MarkerIndex + "base64,".length());
            }
        }

        payload = payload.replaceAll("\\s+", "");
        if (payload.isEmpty()) return "";

        try {
            byte[] imageBytes = Base64.getMimeDecoder().decode(payload);
            Path signPath = pdfFolder1.resolve(filename + "-" + role + "." + ext).normalize();
            Files.write(signPath, imageBytes);
            System.out.println("[SIGN] " + role + " image saved: " + signPath + " (" + imageBytes.length + " bytes)");
            return signPath.toUri().toString();
        } catch (IllegalArgumentException | IOException e) {
            System.out.println("[SIGN] ERROR writing " + role + " image: " + e.getMessage());
            e.printStackTrace();
            return "";
        }
    }

    private String toXmlWorkerSafeHtml(String html) {
        if (html == null) return "";
        String out = html;

        // XMLWorker parses XHTML, so common void tags must be self-closing.
        out = out.replaceAll("(?i)</br\\s*>", "");
        out = out.replaceAll("(?i)<br\\s*>", "<br/>");
        out = out.replaceAll("(?i)<hr\\s*>", "<hr/>");
        out = out.replaceAll("(?i)<img([^>]*?)(?<!/)>", "<img$1/>");
        out = out.replaceAll("(?i)<meta([^>]*?)(?<!/)>", "<meta$1/>");
        out = out.replaceAll("(?i)<link([^>]*?)(?<!/)>", "<link$1/>");
        out = out.replaceAll("(?i)<input([^>]*?)(?<!/)>", "<input$1/>");
        out = out.replaceAll("(?i)<col([^>]*?)(?<!/)>", "<col$1/>");

        return out;
    }

    public String AnContfiles(AnCont contData){




        String htmlContent  = "<html>"
                + "<body>"
                + "<p style='text-align: justify; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;' ><b style='font-size: 10pt; text-align: justify;'>&nbsp;[별지 3의2]&nbsp;</b><span style='font-size: 10pt; text-align: justify;'>&lt;개정 2022.1.21.&gt;&nbsp;</span></p>"
                + "<table border='1' cellspacing='0' cellpadding='5' style='word-break: normal; font-size: 10pt; width: 100%; border: 1px none rgb(0, 0, 0); border-collapse: collapse; height:1240.69px;'>"

                + "<tr>"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 100%; height: 50px;' colspan='7'>"
                + "<p style='margin: 0px 0px 8px; line-height: normal; font-size: 10pt;  text-align: justify;'><span style='font-size: 10pt; '>[액법 시행규칙 별지 제50호서식]</span></p>"
                + "<p style='margin: 0px 0px 8px; line-height: normal; font-size: 10pt;  text-align: center; '><b style='font-size: 16pt;'>액화석유가스 안전공급계약서</b><b style='font-size: 10pt;'></b></p>"
                + "<p style='margin: 0px 0px 8px; line-height: normal; font-size: 10pt;  text-align: justify;'><b style='font-size: 10pt;'>&nbsp;</b><span style='font-size: 10pt; '>※ [&nbsp;]에는 해당되는 곳에 √표를 합니다.</span><span style='font-size: 10pt; '>(앞쪽)</span></p>"
                + "</td>"
                + "</tr>"

                + "<tr>"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 100%; height: 20px;' colspan='7'>"
                + "<p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 1; font-size: 10pt;'><span style='font-size: 10pt; '>&nbsp; 「액화석유가스의 안전관리 및 사업법 시행규칙」 별표 13 제3호가목에 따라 당사(점)[이하 '당사(점)'이라 합니다]</span></p>"
                + "<p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 1; font-size: 10pt;'><span style='font-size: 10pt; '>는 고객(이하'고객'이라 합니다)과 액화석유가스의 안전공급에 관하여 다음과 같이 계약을 체결합니다.</span></p>"
                + "</td>"
                + "</tr>"

                + "<tr>"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 13%; height: 23px;'>"
                + "<p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; '><span style='font-size: 10pt; '>가스의</span></p><p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; '><span style='font-size: 10pt; '>전달방법</span></p>"
                + "</td>"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 87%; height: 23px;' colspan='6'>"
                + "<p style='margin: 0cm 0cm 8pt; line-height: 1.2; font-size: 10pt; text-align: justify;'><b style='font-size: 10pt;'>&nbsp; &nbsp;</b><span style='font-size: 10pt; '>&nbsp; 당사(점)는 액화석유가스(LPG)가"
                + "충전된 용기를 가스사용에 지장이 없도록, 계획된 배달날짜 또는 고객이 주문할</span><b style='font-size: 10pt;'>&nbsp;</b><span style='font-size: 10pt; '>때마다 신속히 배달하겠으며, 사용시설에 직접 연결하여 드립니다. 다만, 체적으로 판매할 경우에는 사용 중인&nbsp;</span><span style='font-size: 10pt; '>용기 안에 있는 가스가 떨어지면 자동적으로 다른 용기에서 가스가 공급될"
                + "수 있도록 항상 충전된 예비용기를&nbsp;</span><span style='font-size: 10pt; '>연결하여 드리겠습니다.</span></p>"
                + "</td>"
                + "</tr>"


                + "<tr>"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 20%; height: 156.482px;'>"
                + "<p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; '><span style='font-size: 10pt; '>가스의</span></p><p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; '><span style='font-size: 10pt; '>계량방법과&nbsp;</span></p><p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; '><span style='font-size: 10pt; '>가스요금</span></p>"
                + "</td>"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 80%; height: 156.482px;' colspan='6'>"
                + "<p style='margin: 0cm 0cm 8pt; line-height: 1; font-size: 10pt; text-align: justify;'><span style='font-size: 10pt; '><b>&nbsp;&nbsp;</b>1. 체적(계량기로 계량함)으로 판매할 경우</span></p><p style='margin: 0cm 0cm 8pt; line-height: 1; font-size: 10pt;  text-align: justify;'><span style='font-size: 10pt; '><b>&nbsp; &nbsp;&nbsp;</b>가. 매월 가스사용량을 검침하여 별첨의 &lt;체적판매 가스요금표&gt;에 따라 계산된 가스요금을 받으며, 만약&nbsp;</span><span style='font-size: 10pt; '>가스계량기의 고장 등으로"
                + "계량이 잘 되지 않은 경우에는 최근 3개월간 검침된 양의 평균수치를 기준으로 하여</span><b style='font-size: 10pt;'>&nbsp;</b><span style='font-size: 10pt; '>가스요금을 계산합니다.</span></p><p style='margin: 0cm 0cm 8pt; line-height: 1; font-size: 10pt;  text-align: justify;'><span style='font-size: 10pt; '><b>&nbsp; &nbsp;&nbsp;</b>나. 가스요금의 가격구성과 요금체계의 설명은 가스요금표에 적혀 있고, 가스요금을"
                + "조정한 경우에는 조정된</span><b style='font-size: 10pt;'>&nbsp;</b><span style='font-size: 10pt; '>가스요금을 적용하기 전에 알려드리겠습니다.</span></p><p style='margin: 0cm 0cm 8pt; line-height: 1; font-size: 10pt; text-align: justify;'><span style='font-size: 10pt; '><b>&nbsp;&nbsp;</b>2. 중량으로"
                + "판매할 경우</span></p><p style='margin: 0cm 0cm 8pt; line-height: 1; font-size: 10pt;  text-align: justify;'><b style='font-size: 10pt;'>&nbsp;</b><span style='font-size: 10pt; '>&nbsp;&nbsp; 정량표시를"
                + "한 용기로 배달하고, 별첨의 &lt;중량판매 가스요금표&gt;에 따라 가스요금을 받으며, 가스요금을&nbsp;</span><span style='font-size: 10pt; '>조정한 경우에는 조정된"
                + "가스요금을 적용하기 전에 알려드리겠습니다.</span></p><p style='margin: 0cm 0cm 8pt; line-height: 1; font-size: 10pt;  text-align: justify;'><span style='font-size: 10pt; '><b>&nbsp;&nbsp;</b>3. 가스요금이"
                + "납기 내에 납부되지 않은 경우 당사(점)는 고객에게 납기"
                + "경과분에 대해 관할 허가관청이&nbsp;</span><span style='font-size: 10pt; '>인정하는 연체료(가산금)를"
                + "부과할 수 있고, 사전 연락 후 가스공급을 중지할 수 있습니다.</span></p><p style='margin: 0cm 0cm 8pt; line-height: 1; font-size: 10pt;  text-align: justify;'><b style='font-size: 10pt;'>&nbsp; &nbsp;</b><span style='font-size: 10pt; '>&nbsp; ※ 별첨: 체적(중량)판매 가스요금표 1부</span></p>"
                + "</td>"
                + "</tr>"

                + "<tr>"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 20%; height: 124.323px;'>"
                + "<p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; '><span style='font-size: 10pt; '>공급설비와&nbsp;</span></p><p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; '><span style='font-size: 10pt; '>소비설비에&nbsp;</span></p><p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; '><span style='font-size: 10pt; '>대한&nbsp;</span></p><p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; '><span style='font-size: 10pt; '>비용부담 등</span></p>"
                + "</td>"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 80%; height: 124.323px;' colspan='6'>"
                + "<p style='margin: 0cm 0cm 8pt; line-height: 107%; font-size: 10pt;  text-align: justify;'><span style='font-size: 10pt; '>&nbsp;1. 공급설비와"
                + "소비설비의 설치·변경 등의 비용부담방법은 다음과 같습니다.</span></p><p style='margin: 0cm 0cm 8pt; line-height: 107%; font-size: 10pt;  text-align: justify;'><span style='font-size: 10pt; '>&nbsp; 가. 당사(점) 소유의 공급설비(체적판매의 경우 용기 출구에서 계량기 출구까지의 설비를 말합니다)를"
                + "사용하여 고객이 당사(점)으로부터 가스를 공급받는 경우 그"
                + "설비의 사용에 대해 별도의 사용료를 부과하지 않습니다. 다만, 고객의"
                + "요청으로 계약기간을 정하지 않는 경우에는 당사(점)은 그"
                + "사용료를 부과할 수 있고, 고객의 사정(건물 보수 등)으로 공급설비의 변경·교환·수리"
                + "등이 필요한 경우에는 고객이 부담합니다.</span></p><p style='margin: 0cm 0cm 8pt; line-height: 107%; font-size: 10pt;  text-align: justify;'><span style='font-size: 10pt; '>&nbsp; 나. 소비설비(체적판매의 경우 계량기 출구에서 연소기까지의 설비를 말하고, 중량판매의 경우 용기 출구에서 연소기까지의 설비를 말합니다)의 설치·변경 등은 고객이 부담합니다.</span></p><p style='margin: 0cm 0cm 8pt; line-height: 107%; font-size: 10pt;  text-align: justify;'><span style='font-size: 10pt; '>&nbsp;2. 고객은"
                + "당사(점) 소유의 설비로 다른 가스공급자로부터 가스를 공급받을"
                + "수 없습니다.</span></p>"
                + "</td>"
                + "</tr>"

                + "<tr>"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 20%; height: 10px;'>"
                + "<p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; '><span style='font-size: 10pt; '>계약기간</span></p>"
                + "</td>"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 80%; height: 10px;' colspan='6'>"
                + "<p style='margin: 0cm 0cm 8pt; line-height: 107%; font-size: 10pt;  text-align: justify;'><span style='font-size: 10pt; '>&nbsp; 이"
                + "계약의 유효기간은&nbsp; &nbsp; &nbsp;&nbsp; 년&nbsp;&nbsp;&nbsp; 월&nbsp; &nbsp; 일부터&nbsp; &nbsp;&nbsp;&nbsp;&nbsp; 년&nbsp; &nbsp; 월&nbsp; &nbsp; 일까지로 하고, 당사(점)은 계약만료일 15일"
                + "전에 고객에게 계약만료를 알리며, 고객이 계약만료일 전에 계약해지를 알리지 않은 경우 계약기간은 6개월씩 연장됩니다.</span></p><p style='margin: 0cm 0cm 8pt; line-height: 107%; font-size: 10pt;  text-align: justify;'><span style='font-size: 10pt; '>&nbsp;※ 계약기간: 체적판매방법으로 공급하는 경우 및 중량판매방법(용기집합설비를 설치한"
                + "주택에 공급하는 경우에만을 말합니다)으로 공급하는 경우로서 공급설비를 당사(점)의 부담으로 설치한 경우 당사(점)와 체결하는 최초의 안전공급계약은 1년(주택의 경우에는 2년) 이상으로"
                + "하고, 공급설비와 소비설비 모두를 당사(점)의 부담으로 설치한 경우 당사(점)와"
                + "체결하는 최초의 안전공급계약은 2년(주택의 경우에는 3년) 이상으로 합니다.&nbsp;</span></p>"
                + "</td>"
                + "</tr>"

                + "<tr>"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 20%; height: 256.141px;'>"
                + "<p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; '><span style='font-size: 10pt; '>계약의 해지</span></p>"
                + "</td>"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 80%; height: 256.141px;' colspan='6'>"
                + "<p style='margin: 0cm 0cm 8pt; line-height: 1; font-size: 10pt;  text-align: justify;'><span style='font-size: 10pt; '>&nbsp; 고객이"
                + "당사(점)와 계약한 안전공급계약의 해지를 요청할 경우 당사(점)는 5일 이내에 고객과"
                + "가스요금 등을 정산 및 납부하고 계약을 해지하여야 하며, 다음의 방법에 따라야 합니다.</span></p><p style='margin: 0cm 0cm 8pt; line-height: 1; font-size: 10pt;  text-align: justify;'><span style='font-size: 10pt; '>&nbsp;1. 계약기간이"
                + "만료되어 고객이 계약해지를 요구하는 경우 당사(점)는 그"
                + "설비를 철거하거나 고객이 원하는 새로운 가스공급자에게 양도·양수합니다.</span></p><p style='margin: 0cm 0cm 8pt; line-height: 1; font-size: 10pt;  text-align: justify;'><span style='font-size: 10pt; '>&nbsp;2. 계약기간"
                + "내에 당사(점)이 무단으로 가스공급의 중단, 사전 협의 없는 요금의 인상, 안전점검 미실시, 그 밖에 안전관리 업무를 하지 않은 경우로서 고객이 그 설비의 철거를 원할 경우 당사(점)은 그 설비를 철거합니다.</span></p><p style='margin: 0cm 0cm 8pt; line-height: 1; font-size: 10pt;  text-align: justify;'><span style='font-size: 10pt; '>&nbsp;3. 제2호 외의 사유로 계약기간 내에 고객이 계약해지를 요청하는 경우 고객은 당사(점)가 설치한 설비에 대하여 철거비용을 부담해야 합니다. 다만, 고객이 그 설비의 철거를 원하지 않고 새로운 가스공급자가 있는 경우 당사(점)는 제1호의 방법으로 할 수 있습니다.</span></p><p style='margin: 0cm 0cm 8pt; line-height: 1; font-size: 10pt;  text-align: justify;'><span style='font-size: 10pt; '>&nbsp;4. 공급설비가"
                + "고객의 소유인 경우 당사(점)이 구매·철거합니다. 다만, 고객이"
                + "공급설비의 철거를 원하지 않는 경우에는 당사(점)은 용기만"
                + "구매·철거하고, 새로운 가스공급자는 고객의 공급설비를 구매해야"
                + "합니다.</span></p><p style='margin: 0cm 0cm 8pt; line-height: 1; font-size: 10pt;  text-align: justify;'><span style='font-size: 10pt; '>&nbsp;5. 당사(점)의 귀책사유 없이 고객이 계약을 해지하려면 고객은 다음의 방법에"
                + "따라 산정한 철거비용 등을 당사(점)에 납부하여야 합니다.</span></p><p style='margin: 0cm 0cm 8pt; line-height: 1; font-size: 10pt;  text-align: justify;'><span style='font-size: 10pt; '>&nbsp; 가. 당사(점)이 설치한 설비의"
                + "철거비용: 통계청의 건설임금단가(배관공)를 적용</span></p><p style='margin: 0cm 0cm 8pt; line-height: 1; font-size: 10pt;  text-align: justify;'><span style='font-size: 10pt; '>&nbsp; 나. 소비설비[당사(점)의 부담으로 설치한 경우만 해당합니다]의 시가 상당액: 계약해지 당시의 신규제품가격(기획재정부장관이 정하는 기준에 적합한"
                + "전문가격조사기관으로서 기획재정부장관에게 등록한 기관이 조사하여 공표한 가격을 말합니다)에서 1년에 20%씩 뺀 금액</span></p><p style='margin: 0cm 0cm 8pt; line-height: 1; font-size: 10pt;  text-align: justify;'><span style='font-size: 10pt; '>&nbsp;6. 계약기간이"
                + "지난 이후 당사(점)의 부담으로 설치한 소비설비는 계약서에"
                + "별도로 고객에게 소유권이 이전되는 것으로 명시한 경우에 한정하여 고객의 소유로 합니다.</span></p><p style='margin: 0cm 0cm 8pt; line-height: 1; font-size: 10pt;  text-align: justify;'><span style='font-size: 10pt; '>&nbsp;7. 계약의"
                + "해지는 요금의 정산과 공급설비에 대한 보상시 발행한 영수증 등으로 확인할 수 있어야 합니다.&nbsp;</span></p>"
                + "</td>"
                + "</tr>"

                + "<tr>"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 20%; height: 141.133px;'>"
                + "<p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; '><span style='font-size: 10pt; '>공급설비와&nbsp;</span></p><p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; '><span style='font-size: 10pt; '>소비설비의&nbsp;</span></p><p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; '><span style='font-size: 10pt; '>관리방법</span></p>"
                + "</td>"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 80%; height: 141.133px;' colspan='6'>"
                + "<p style='margin: 0cm 0cm 8pt; line-height: 107%; font-size: 10pt;  text-align: justify;'><span style='font-size: 10pt; '>&nbsp;1. 공급설비에"
                + "대해서는, 당사(점)가"
                + "법규에서 정하는 바에 따라 설비의 유지·관리를 위한 점검을 합니다.</span></p><p style='margin: 0cm 0cm 8pt; line-height: 107%; font-size: 10pt;  text-align: justify;'><span style='font-size: 10pt; '>&nbsp;2. 소비설비에"
                + "대해서는, 당사(점)가"
                + "법규에서 정하는 바에 따라 점검을 실시하나, 일상의 관리는 「가스안전 계도물」등을 참고하여 관리하여"
                + "주시고, 고객은 당사(점)의"
                + "점검을 거부해서는 안 되며, 점검 결과 기준에 맞지 않거나 가스누출 등의 우려가 있을 경우 당사(점)는 안전상 가스사용을 일시 중단시킬 수 있으며, 중단조치 후 무단으로 가스를 사용하였을 경우 당사(점)는 그로 인한 책임을 지지 않습니다.</span></p><p style='margin: 0cm 0cm 8pt; line-height: 107%; font-size: 10pt;  text-align: justify;'><span style='font-size: 10pt; '>&nbsp;3. 고객은"
                + "당사(점)의 시설개선 권고를 받은 경우 당사(점)가 정한 날까지 시설 개선을 해야 합니다. 시설 개선 권고를 이행하지 않는 경우 당사(점)는 그 사실을 관할관청에 알려야 합니다.</span></p><p style='margin: 0cm 0cm 8pt; line-height: 107%; font-size: 10pt;  text-align: justify;'><span style='font-size: 10pt; '>&nbsp;4. 고객은"
                + "당사(점)와 사전 협의 없이 당사(점) 소유의 설비를 임의로 철거하거나 변경할 수 없습니다. 다만, 협의가 이루어지지 않아 고객이 당사(점) 소유 설비의 철거를 요청한 경우 5일 이내에 철거하겠습니다.</span></p><p style='margin: 0cm 0cm 8pt; line-height: 107%; font-size: 10pt;  text-align: justify;'><span style='font-size: 10pt; '>&nbsp;5. 당사(점)는 고객이 관할관청의 수리 또는 개선명령을 이행하기 위하여 당사(점)에게 고객의 소비설비의 수리 또는 개선을 요청한 경우 2일 이내에 고객의 소비설비를 개선하여 드리겠습니다. 다만, 이에 필요한 비용은 고객이 부담합니다.</span></p>"
                + "</td>"
                + "</tr>"

                + "</table>"
                + "<p style='margin: 0cm 0cm 8pt; text-align: justify; line-height: 107%; font-size: 10pt; '><span style='font-size: 10pt; '>※ 고객과 관련된 정보는 다른 목적으로 사용하거나 누출할 수 없습니다.</span></p>"
                + "</body>"
                + "</html>";

        return htmlContent;

    }


    /*
     * iText 라이브러리를 사용한 PDF 파일 생성
     * CSS , Font 설정 기능 포함
     * */
    public void createPDFTest(String filename) {

        // 최초 문서 사이즈 설정
        Document document = new Document(PageSize.B4, 20, 20, 0, 0);

        Path AnContfilepdf =  pdfFolder1.resolve(filename).normalize();
        String filePathPdf = AnContfilepdf + ".pdf";

        try {

            // PDF 파일 생성
            PdfWriter pdfWriter = PdfWriter.getInstance(document, new FileOutputStream(filePathPdf));
            // PDF 파일에 사용할 폰트 크기 설정
            pdfWriter.setInitialLeading(10.5f);
            // PDF 파일 열기
            document.open();

            // XMLWorkerHelper xmlWorkerHelper = XMLWorkerHelper.getInstance();
            // CSS 설정 변수 세팅
            CSSResolver cssResolver = new StyleAttrCSSResolver();
            CssFile cssFile = null;

            try {
                /*
                 * CSS 파일 설정
                 * 기존 방식은 FileInputStream을 사용했으나, jar 파일로 빌드 시 파일을 찾을 수 없는 문제가 발생
                 * 따라서, ClassLoader를 사용하여 파일을 읽어오는 방식으로 변경
                 */
                InputStream cssStream = getClass().getClassLoader().getResourceAsStream("static/css/Pdf.css");

                // CSS 파일 담기
                cssFile = XMLWorkerHelper.getCSS(cssStream);
//                cssFile = XMLWorkerHelper.getCSS(new FileInputStream("src/main/resources/static/css/test.css"));
            } catch (Exception e) {
                throw new IllegalArgumentException("PDF CSS 파일을 찾을 수 없습니다.");
            }

            if(cssFile == null) {
                throw new IllegalArgumentException("PDF CSS 파일을 찾을 수 없습니다.");
            }

            // CSS 파일 적용
            cssResolver.addCss(cssFile);

            // PDF 파일에 HTML 내용 삽입
            XMLWorkerFontProvider fontProvider = new XMLWorkerFontProvider(XMLWorkerFontProvider.DONTLOOKFORFONTS);

            /*
             * 폰트 설정
             * CSS 와 다르게, fontProvider.register() 메소드를 사용하여 폰트를 등록해야 함
             * 해당 메소드 내부에서 경로처리를 하여 개발, 배포 시 폰트 파일을 찾을 수 있도록 함
             * */
            try {
                //fontProvider.register("static/font/NotoSansKR-Regular.woff", "NotoSansKR");
                fontProvider.register("static/font/AppleSDGothicNeoR.ttf", "AppleSDGothicNeo");
            } catch (Exception e) {
                throw new IllegalArgumentException("PDF 폰트 파일을 찾을 수 없습니다.");
            }

            if(fontProvider.getRegisteredFonts() == null) {
                throw new IllegalArgumentException("PDF 폰트 파일을 찾을 수 없습니다.");
            }

            // 사용할 폰트를 담아두었던 내용을
            // CSSAppliersImpl에 담아 적용
            CssAppliers cssAppliers = new CssAppliersImpl(fontProvider);

            // HTML Pipeline 생성
            HtmlPipelineContext htmlPipelineContext = new HtmlPipelineContext(cssAppliers);
            htmlPipelineContext.setTagFactory(Tags.getHtmlTagProcessorFactory());
            // 서명 이미지 로드를 위한 ImageProvider 설정
            htmlPipelineContext.setImageProvider(new AbstractImageProvider() {
                @Override
                public String getImageRootPath() {
                    return pdfFolder1.toAbsolutePath().toString() + File.separator;
                }
                @Override
                public Image retrieve(String src) {
                    try {
                        // file:// URI → 파일 경로 변환
                        String path = src;
                        if (src.startsWith("file:")) {
                            path = new java.net.URI(src).getPath();
                        }
                        File imgFile = new File(path);
                        if (!imgFile.isAbsolute()) {
                            imgFile = new File(getImageRootPath(), path);
                        }
                        if (imgFile.exists()) {
                            System.out.println("[SIGN] ImageProvider loading: " + imgFile.getAbsolutePath());
                            Image img = Image.getInstance(imgFile.getAbsolutePath());
                            store(src, img);
                            return img;
                        }
                        System.out.println("[SIGN] ImageProvider file NOT found: " + imgFile.getAbsolutePath());
                    } catch (Exception e) {
                        System.out.println("[SIGN] ImageProvider error: " + e.getMessage());
                        e.printStackTrace();
                    }
                    return null;
                }
            });

            // ========================================================================================
            // Pipelines
            PdfWriterPipeline pdfWriterPipeline = new PdfWriterPipeline(document, pdfWriter);
            HtmlPipeline htmlPipeline = new HtmlPipeline(htmlPipelineContext, pdfWriterPipeline);
            CssResolverPipeline cssResolverPipeline = new CssResolverPipeline(cssResolver, htmlPipeline);
            // ========================================================================================


            // ========================================================================================
            // XMLWorker
            XMLWorker xmlWorker = new XMLWorker(cssResolverPipeline, true);
            XMLParser xmlParser = new XMLParser(true, xmlWorker, StandardCharsets.UTF_8);
            // ========================================================================================


            /* HTML 내용을 담은 String 변수
            주의점
            1. HTML 태그는 반드시 닫아야 함
            2. xml 기준 html 태그 확인( ex : <p> </p> , <img/> , <col/> )
            위 조건을 지키지 않을 경우 DocumentException 발생
            */
            String htmlStr = toXmlWorkerSafeHtml(AnContfileTest());

            // HTML 내용을 PDF 파일에 삽입
            StringReader stringReader = new StringReader(htmlStr);
            // XML 파싱
            xmlParser.parse(stringReader);
            // PDF 문서 닫기
            document.close();
            // PDF Writer 닫기
            pdfWriter.close();


        } catch (DocumentException e1) {
            throw new IllegalArgumentException("PDF 라이브러리 설정 에러");
        } catch (FileNotFoundException e2) {
            e2.printStackTrace();
            throw new IllegalArgumentException("PDF 파일 생성중 에러");
        } catch (IOException e3) {
            e3.printStackTrace();
            throw new IllegalArgumentException("PDF 파일 생성중 에러2");
        } catch (Exception e4) {
            e4.printStackTrace();
            throw new IllegalArgumentException("PDF 파일 생성중 에러3");
        }
        finally {
            try {
                document.close();
            } catch (Exception e) {
                System.out.println("PDF 파일 닫기 에러");
                e.printStackTrace();
            }
        }

    }

    public String AnContfileTest(){

        String htmlContent  = "<html>"
                + "<body>"
                + "<p style='text-align: justify; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;' ><b style='font-size: 10pt; text-align: justify;'>&nbsp;[별지 3의2]&nbsp;</b><span style='font-size: 10pt; text-align: justify;'>&lt;개정 2022.1.21.&gt;&nbsp;</span></p>"
                + "<table border='1' cellspacing='0' cellpadding='5' style='word-break: normal; font-size: 10pt; width: 100%; border: 1px none rgb(0, 0, 0); border-collapse: collapse; height:1240.69px;'>"

                + "<tr>"
                + "<td style='border: 1px solid rgb(0, 0, 0); height: 50px;' colspan='7'>"
                + "<p style='margin: 0px 0px 8px; line-height: normal; font-size: 10pt;  text-align: justify;'><span style='font-size: 10pt; '>[액법 시행규칙 별지 제50호서식]</span></p>"
                + "<p style='margin: 0px 0px 8px; line-height: normal; font-size: 10pt;  text-align: center; '><b style='font-size: 16pt;'>액화석유가스 안전공급계약서</b><b style='font-size: 10pt;'></b></p>"
                + "<p style='margin: 0px 0px 4px; line-height: normal; font-size: 10pt;  text-align: justify;'><b style='font-size: 10pt;'>&nbsp;</b><span style='font-size: 10pt;'> ※ [&nbsp;]에는 해당되는 곳에 √표를 합니다.&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;(앞쪽)</span></p>"
                + "</td>"
                + "</tr>"

                + "<tr>"
                + "<td style='border: 1px solid rgb(0, 0, 0); height: 20px;' colspan='7'>"
                + "<p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 1; font-size: 10pt;'><span style='font-size: 10pt; '>&nbsp; 「액화석유가스의 안전관리 및 사업법 시행규칙」 별표 13 제3호가목에 따라 당사(점)[이하 '당사(점)'이라 합니다]</span></p>"
                + "<p style='margin: 0cm 0cm 4pt; text-align: center; line-height: 1; font-size: 10pt;'><span style='font-size: 10pt; '>는 고객(이하'고객'이라 합니다)과 액화석유가스의 안전공급에 관하여 다음과 같이 계약을 체결합니다.</span></p>"
                + "</td>"
                + "</tr>"

                + "<tr>"
                + "<td style='border: 1px solid rgb(0, 0, 0); width:10%; height: 23px;' >"
                + "<p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; '><span style='font-size: 10pt; '>가스의</span></p><p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; '><span style='font-size: 10pt; '>전달방법</span></p>"
                + "</td>"
                + "<td style='border: 1px solid rgb(0, 0, 0); height: 23px;' colspan='6'>"
                + "<p style='margin: 0cm 0cm 8pt; line-height: 1.2; font-size: 10pt; text-align: justify;'><b style='font-size: 10pt;'>&nbsp; &nbsp;</b><span style='font-size: 10pt; '>&nbsp; 당사(점)는 액화석유가스(LPG)가"
                + "충전된 용기를 가스사용에 지장이 없도록, 계획된 배달날짜 또는 고객이 주문할</span><b style='font-size: 10pt;'>&nbsp;</b><span style='font-size: 10pt; '>때마다 신속히 배달하겠으며, 사용시설에 직접 연결하여 드립니다. 다만, 체적으로 판매할 경우에는 사용 중인&nbsp;</span><span style='font-size: 10pt; '>용기 안에 있는 가스가 떨어지면 자동적으로 다른 용기에서 가스가 공급될"
                + "수 있도록 항상 충전된 예비용기를&nbsp;</span><span style='font-size: 10pt; '>연결하여 드리겠습니다.</span></p>"
                + "</td>"
                + "</tr>"


                + "<tr>"
                + "<td style='border: 1px solid rgb(0, 0, 0); height: 156.482px;' >"
                + "<p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; '><span style='font-size: 10pt; '>가스의</span></p><p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; '><span style='font-size: 10pt; '>계량방법과&nbsp;</span></p><p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; '><span style='font-size: 10pt; '>가스요금</span></p>"
                + "</td>"
                + "<td style='border: 1px solid rgb(0, 0, 0); height: 156.482px;' colspan='6'>"
                + "<p style='margin: 0cm 0cm 8pt; line-height: 1; font-size: 10pt; text-align: justify;'><span style='font-size: 10pt; '><b>&nbsp;&nbsp;</b>1. 체적(계량기로 계량함)으로 판매할 경우</span></p><p style='margin: 0cm 0cm 8pt; line-height: 1; font-size: 10pt;  text-align: justify;'><span style='font-size: 10pt; '><b>&nbsp; &nbsp;&nbsp;</b>가. 매월 가스사용량을 검침하여 별첨의 &lt;체적판매 가스요금표&gt;에 따라 계산된 가스요금을 받으며, 만약&nbsp;</span><span style='font-size: 10pt; '>가스계량기의 고장 등으로"
                + "계량이 잘 되지 않은 경우에는 최근 3개월간 검침된 양의 평균수치를 기준으로 하여</span><b style='font-size: 10pt;'>&nbsp;</b><span style='font-size: 10pt; '>가스요금을 계산합니다.</span></p><p style='margin: 0cm 0cm 8pt; line-height: 1; font-size: 10pt;  text-align: justify;'><span style='font-size: 10pt; '><b>&nbsp; &nbsp;&nbsp;</b>나. 가스요금의 가격구성과 요금체계의 설명은 가스요금표에 적혀 있고, 가스요금을"
                + "조정한 경우에는 조정된</span><b style='font-size: 10pt;'>&nbsp;</b><span style='font-size: 10pt; '>가스요금을 적용하기 전에 알려드리겠습니다.</span></p><p style='margin: 0cm 0cm 8pt; line-height: 1; font-size: 10pt; text-align: justify;'><span style='font-size: 10pt; '><b>&nbsp;&nbsp;</b>2. 중량으로"
                + "판매할 경우</span></p><p style='margin: 0cm 0cm 8pt; line-height: 1; font-size: 10pt;  text-align: justify;'><b style='font-size: 10pt;'>&nbsp;</b><span style='font-size: 10pt; '>&nbsp;&nbsp; 정량표시를"
                + "한 용기로 배달하고, 별첨의 &lt;중량판매 가스요금표&gt;에 따라 가스요금을 받으며, 가스요금을&nbsp;</span><span style='font-size: 10pt; '>조정한 경우에는 조정된"
                + "가스요금을 적용하기 전에 알려드리겠습니다.</span></p><p style='margin: 0cm 0cm 8pt; line-height: 1; font-size: 10pt;  text-align: justify;'><span style='font-size: 10pt; '><b>&nbsp;&nbsp;</b>3. 가스요금이"
                + "납기 내에 납부되지 않은 경우 당사(점)는 고객에게 납기"
                + "경과분에 대해 관할 허가관청이&nbsp;</span><span style='font-size: 10pt; '>인정하는 연체료(가산금)를"
                + "부과할 수 있고, 사전 연락 후 가스공급을 중지할 수 있습니다.</span></p><p style='margin: 0cm 0cm 8pt; line-height: 1; font-size: 10pt;  text-align: justify;'><b style='font-size: 10pt;'>&nbsp; &nbsp;</b><span style='font-size: 10pt; '>&nbsp; ※ 별첨: 체적(중량)판매 가스요금표 1부</span></p>"
                + "</td>"
                + "</tr>"

                + "<tr>"
                + "<td style='border: 1px solid rgb(0, 0, 0);  height: 124.323px;' >"
                + "<p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; '><span style='font-size: 10pt; '>공급설비와&nbsp;</span></p><p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; '><span style='font-size: 10pt; '>소비설비에&nbsp;</span></p><p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; '><span style='font-size: 10pt; '>대한&nbsp;</span></p><p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; '><span style='font-size: 10pt; '>비용부담 등</span></p>"
                + "</td>"
                + "<td style='border: 1px solid rgb(0, 0, 0); height: 124.323px;' colspan='6'>"
                + "<p style='margin: 0cm 0cm 8pt; line-height: 107%; font-size: 10pt;  text-align: justify;'><span style='font-size: 10pt; '>&nbsp;1. 공급설비와"
                + "소비설비의 설치·변경 등의 비용부담방법은 다음과 같습니다.</span></p><p style='margin: 0cm 0cm 8pt; line-height: 107%; font-size: 10pt;  text-align: justify;'><span style='font-size: 10pt; '>&nbsp; 가. 당사(점) 소유의 공급설비(체적판매의 경우 용기 출구에서 계량기 출구까지의 설비를 말합니다)를"
                + "사용하여 고객이 당사(점)으로부터 가스를 공급받는 경우 그"
                + "설비의 사용에 대해 별도의 사용료를 부과하지 않습니다. 다만, 고객의"
                + "요청으로 계약기간을 정하지 않는 경우에는 당사(점)은 그"
                + "사용료를 부과할 수 있고, 고객의 사정(건물 보수 등)으로 공급설비의 변경·교환·수리"
                + "등이 필요한 경우에는 고객이 부담합니다.</span></p><p style='margin: 0cm 0cm 8pt; line-height: 107%; font-size: 10pt;  text-align: justify;'><span style='font-size: 10pt; '>&nbsp; 나. 소비설비(체적판매의 경우 계량기 출구에서 연소기까지의 설비를 말하고, 중량판매의 경우 용기 출구에서 연소기까지의 설비를 말합니다)의 설치·변경 등은 고객이 부담합니다.</span></p><p style='margin: 0cm 0cm 8pt; line-height: 107%; font-size: 10pt;  text-align: justify;'><span style='font-size: 10pt; '>&nbsp;2. 고객은"
                + "당사(점) 소유의 설비로 다른 가스공급자로부터 가스를 공급받을"
                + "수 없습니다.</span></p>"
                + "</td>"
                + "</tr>"

                + "<tr>"
                + "<td style='border: 1px solid rgb(0, 0, 0); height: 10px;'>"
                + "<p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; '><span style='font-size: 10pt; '>계약기간</span></p>"
                + "</td>"
                + "<td style='border: 1px solid rgb(0, 0, 0); height: 10px;' colspan='6'>"
                + "<p style='margin: 0cm 0cm 8pt; line-height: 107%; font-size: 10pt;  text-align: justify;'><span style='font-size: 10pt; '>&nbsp; 이"
                + "계약의 유효기간은&nbsp; &nbsp; &nbsp;&nbsp; 년&nbsp;&nbsp;&nbsp; 월&nbsp; &nbsp; 일부터&nbsp; &nbsp;&nbsp;&nbsp;&nbsp; 년&nbsp; &nbsp; 월&nbsp; &nbsp; 일까지로 하고, 당사(점)은 계약만료일 15일"
                + "전에 고객에게 계약만료를 알리며, 고객이 계약만료일 전에 계약해지를 알리지 않은 경우 계약기간은 6개월씩 연장됩니다.</span></p><p style='margin: 0cm 0cm 8pt; line-height: 107%; font-size: 10pt;  text-align: justify;'><span style='font-size: 10pt; '>&nbsp;※ 계약기간: 체적판매방법으로 공급하는 경우 및 중량판매방법(용기집합설비를 설치한"
                + "주택에 공급하는 경우에만을 말합니다)으로 공급하는 경우로서 공급설비를 당사(점)의 부담으로 설치한 경우 당사(점)와 체결하는 최초의 안전공급계약은 1년(주택의 경우에는 2년) 이상으로"
                + "하고, 공급설비와 소비설비 모두를 당사(점)의 부담으로 설치한 경우 당사(점)와"
                + "체결하는 최초의 안전공급계약은 2년(주택의 경우에는 3년) 이상으로 합니다.&nbsp;</span></p>"
                + "</td>"
                + "</tr>"

                + "<tr>"
                + "<td style='border: 1px solid rgb(0, 0, 0); height: 256.141px;' >"
                + "<p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; '><span style='font-size: 10pt; '>계약의 해지</span></p>"
                + "</td>"
                + "<td style='border: 1px solid rgb(0, 0, 0); height: 256.141px;' colspan='6'>"
                + "<p style='margin: 0cm 0cm 8pt; line-height: 1; font-size: 10pt;  text-align: justify;'><span style='font-size: 10pt; '>&nbsp; 고객이"
                + "당사(점)와 계약한 안전공급계약의 해지를 요청할 경우 당사(점)는 5일 이내에 고객과"
                + "가스요금 등을 정산 및 납부하고 계약을 해지하여야 하며, 다음의 방법에 따라야 합니다.</span></p><p style='margin: 0cm 0cm 8pt; line-height: 1; font-size: 10pt;  text-align: justify;'><span style='font-size: 10pt; '>&nbsp;1. 계약기간이"
                + "만료되어 고객이 계약해지를 요구하는 경우 당사(점)는 그"
                + "설비를 철거하거나 고객이 원하는 새로운 가스공급자에게 양도·양수합니다.</span></p><p style='margin: 0cm 0cm 8pt; line-height: 1; font-size: 10pt;  text-align: justify;'><span style='font-size: 10pt; '>&nbsp;2. 계약기간"
                + "내에 당사(점)이 무단으로 가스공급의 중단, 사전 협의 없는 요금의 인상, 안전점검 미실시, 그 밖에 안전관리 업무를 하지 않은 경우로서 고객이 그 설비의 철거를 원할 경우 당사(점)은 그 설비를 철거합니다.</span></p><p style='margin: 0cm 0cm 8pt; line-height: 1; font-size: 10pt;  text-align: justify;'><span style='font-size: 10pt; '>&nbsp;3. 제2호 외의 사유로 계약기간 내에 고객이 계약해지를 요청하는 경우 고객은 당사(점)가 설치한 설비에 대하여 철거비용을 부담해야 합니다. 다만, 고객이 그 설비의 철거를 원하지 않고 새로운 가스공급자가 있는 경우 당사(점)는 제1호의 방법으로 할 수 있습니다.</span></p><p style='margin: 0cm 0cm 8pt; line-height: 1; font-size: 10pt;  text-align: justify;'><span style='font-size: 10pt; '>&nbsp;4. 공급설비가"
                + "고객의 소유인 경우 당사(점)이 구매·철거합니다. 다만, 고객이"
                + "공급설비의 철거를 원하지 않는 경우에는 당사(점)은 용기만"
                + "구매·철거하고, 새로운 가스공급자는 고객의 공급설비를 구매해야"
                + "합니다.</span></p><p style='margin: 0cm 0cm 8pt; line-height: 1; font-size: 10pt;  text-align: justify;'><span style='font-size: 10pt; '>&nbsp;5. 당사(점)의 귀책사유 없이 고객이 계약을 해지하려면 고객은 다음의 방법에"
                + "따라 산정한 철거비용 등을 당사(점)에 납부하여야 합니다.</span></p><p style='margin: 0cm 0cm 8pt; line-height: 1; font-size: 10pt;  text-align: justify;'><span style='font-size: 10pt; '>&nbsp; 가. 당사(점)이 설치한 설비의"
                + "철거비용: 통계청의 건설임금단가(배관공)를 적용</span></p><p style='margin: 0cm 0cm 8pt; line-height: 1; font-size: 10pt;  text-align: justify;'><span style='font-size: 10pt; '>&nbsp; 나. 소비설비[당사(점)의 부담으로 설치한 경우만 해당합니다]의 시가 상당액: 계약해지 당시의 신규제품가격(기획재정부장관이 정하는 기준에 적합한"
                + "전문가격조사기관으로서 기획재정부장관에게 등록한 기관이 조사하여 공표한 가격을 말합니다)에서 1년에 20%씩 뺀 금액</span></p><p style='margin: 0cm 0cm 8pt; line-height: 1; font-size: 10pt;  text-align: justify;'><span style='font-size: 10pt; '>&nbsp;6. 계약기간이"
                + "지난 이후 당사(점)의 부담으로 설치한 소비설비는 계약서에"
                + "별도로 고객에게 소유권이 이전되는 것으로 명시한 경우에 한정하여 고객의 소유로 합니다.</span></p><p style='margin: 0cm 0cm 8pt; line-height: 1; font-size: 10pt;  text-align: justify;'><span style='font-size: 10pt; '>&nbsp;7. 계약의"
                + "해지는 요금의 정산과 공급설비에 대한 보상시 발행한 영수증 등으로 확인할 수 있어야 합니다.&nbsp;</span></p>"
                + "</td>"
                + "</tr>"

                + "<tr>"
                + "<td style='border: 1px solid rgb(0, 0, 0); height: 141.133px;' >"
                + "<p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; '><span style='font-size: 10pt; '>공급설비와&nbsp;</span></p><p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; '><span style='font-size: 10pt; '>소비설비의&nbsp;</span></p><p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; '><span style='font-size: 10pt; '>관리방법</span></p>"
                + "</td>"
                + "<td style='border: 1px solid rgb(0, 0, 0); height: 141.133px;' colspan='6'>"
                + "<p style='margin: 0cm 0cm 8pt; line-height: 107%; font-size: 10pt;  text-align: justify;'><span style='font-size: 10pt; '>&nbsp;1. 공급설비에"
                + "대해서는, 당사(점)가"
                + "법규에서 정하는 바에 따라 설비의 유지·관리를 위한 점검을 합니다.</span></p><p style='margin: 0cm 0cm 8pt; line-height: 107%; font-size: 10pt;  text-align: justify;'><span style='font-size: 10pt; '>&nbsp;2. 소비설비에"
                + "대해서는, 당사(점)가"
                + "법규에서 정하는 바에 따라 점검을 실시하나, 일상의 관리는 「가스안전 계도물」등을 참고하여 관리하여"
                + "주시고, 고객은 당사(점)의"
                + "점검을 거부해서는 안 되며, 점검 결과 기준에 맞지 않거나 가스누출 등의 우려가 있을 경우 당사(점)는 안전상 가스사용을 일시 중단시킬 수 있으며, 중단조치 후 무단으로 가스를 사용하였을 경우 당사(점)는 그로 인한 책임을 지지 않습니다.</span></p><p style='margin: 0cm 0cm 8pt; line-height: 107%; font-size: 10pt;  text-align: justify;'><span style='font-size: 10pt; '>&nbsp;3. 고객은"
                + "당사(점)의 시설개선 권고를 받은 경우 당사(점)가 정한 날까지 시설 개선을 해야 합니다. 시설 개선 권고를 이행하지 않는 경우 당사(점)는 그 사실을 관할관청에 알려야 합니다.</span></p><p style='margin: 0cm 0cm 8pt; line-height: 107%; font-size: 10pt;  text-align: justify;'><span style='font-size: 10pt; '>&nbsp;4. 고객은"
                + "당사(점)와 사전 협의 없이 당사(점) 소유의 설비를 임의로 철거하거나 변경할 수 없습니다. 다만, 협의가 이루어지지 않아 고객이 당사(점) 소유 설비의 철거를 요청한 경우 5일 이내에 철거하겠습니다.</span></p><p style='margin: 0cm 0cm 8pt; line-height: 107%; font-size: 10pt;  text-align: justify;'><span style='font-size: 10pt; '>&nbsp;5. 당사(점)는 고객이 관할관청의 수리 또는 개선명령을 이행하기 위하여 당사(점)에게 고객의 소비설비의 수리 또는 개선을 요청한 경우 2일 이내에 고객의 소비설비를 개선하여 드리겠습니다. 다만, 이에 필요한 비용은 고객이 부담합니다.</span></p>"
                + "</td>"
                + "</tr>"

                + "</table>"
                + "<p style='margin: 0cm 0cm 8pt; text-align: justify; line-height: 107%; font-size: 10pt; '><span style='font-size: 10pt; '>※ 고객과 관련된 정보는 다른 목적으로 사용하거나 누출할 수 없습니다.</span></p>"
                + "<p style='margin: 0cm 0cm 8pt; text-align: right; line-height: 107%; font-size: 10pt; '><span style='font-size: 10pt; '>210mm x 297mm(백상지 60g/m2(재활용품)</span></p><br>&nbsp;</br>"

                + "<p style='text-align: right; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;' ><b style='font-size: 10pt; text-align: justify;'>&nbsp;[뒤쪽]&nbsp;]</b></p>"

                + "<table border='1' cellspacing='0' cellpadding='5' style='word-break: normal; font-size: 10pt; width: 100%; border: 1px none rgb(0, 0, 0); border-collapse: collapse; height:1240.69px;'>"

                + "<tr>"
                + "<td style='border: 1px solid rgb(0, 0, 0); width:10%; height: 20px;' width:14% >"
                + "<p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 1; font-size: 10pt; '>가스안전</p><p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 1; font-size: 10pt; '>계도물</p>"
                + "</td>"
                + "<td style='border: 1px solid rgb(0, 0, 0); height: 20px;' colspan='6'>"
                + "<p style='font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'>&nbsp;&nbsp;<span style=' font-size: 10pt; text-align: justify;'>당사</span><span style=' font-size: 10pt; text-align: justify;'>(</span><span style=' font-size: 10pt; text-align: justify;'>점</span><span style=' font-size: 10pt; text-align: justify;'>)</span><span style=' font-size: 10pt; text-align: justify;'>는 액화석유가스의"
                + "안전사용을 위한 주의사항을 적은 서면을</span><span style=' font-size: 10pt; text-align: justify;'> 6</span><span style=' font-size: 10pt; text-align: justify;'>개월에</span><span style=' font-size: 10pt; text-align: justify;'> 1</span><span style=' font-size: 10pt; text-align: justify;'>회 이상"
                + "전달하겠으며</span><span style=' font-size: 10pt; text-align: justify;'>, </span><span style=' font-size: 10pt; text-align: justify;'>고객은 반드시 그 내용을 확인하고</span><span style=' font-size: 10pt; text-align: justify;'>, </span><span style=' font-size: 10pt; text-align: justify;'>가스를"
                + "안전하게 사용하시기 바랍니다</span><span style=' font-size: 10pt; text-align: justify;'>.</span></p>"
                + "</td>"
                + "</tr>"

                + "<tr>"
                + "<td style='border: 1px solid rgb(0, 0, 0); height: 285.844px;' >"
                + "<p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; '>안전책임에&nbsp;</p><p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; '>관한 사항</p>"
                + "</td>"
                + "<td style='border: 1px solid rgb(0, 0, 0); height: 285.844px;' colspan='6'>"
                + "<p style='margin-top:0cm;margin-right:0cm;margin-bottom:8.0pt;margin-left:0cm;text-align:justify;text-justify:inter-ideograph;line-height:107%;text-autospace:none;word-break:break-hangul;font-size:10.0pt;'>&nbsp;1. 고객의"
                + "안전책임</p><p style='margin-top:0cm;margin-right:0cm;margin-bottom:8.0pt;margin-left:0cm;text-align:justify;text-justify:inter-ideograph;line-height:107%;text-autospace:none;word-break:break-hangul;font-size:10.0pt;'>&nbsp; 가. 고객은 가스를 사용할 때 이 계약서와 가스안전 계도물에 적힌 안전에 관한 주의사항을 준수해야 합니다.</p><p style='margin-top:0cm;margin-right:0cm;margin-bottom:8.0pt;margin-left:0cm;text-align:justify;text-justify:inter-ideograph;line-height:107%;text-autospace:none;word-break:break-hangul;font-size:10.0pt;'>&nbsp; 나. 고객은 당사(점)와 사전"
                + "협의 없이 당사(점) 소유의 설비를 임의로 철거하거나 변경하지"
                + "말아야 합니다.</p><p style='margin-top:0cm;margin-right:0cm;margin-bottom:8.0pt;margin-left:0cm;text-align:justify;text-justify:inter-ideograph;line-height:107%;text-autospace:none;word-break:break-hangul;font-size:10.0pt;'>&nbsp; 다. 당사(점)의 점검 결과"
                + "부적합한 것으로 지적·통지된 사항은 안전을 위하여 신속히 조치하여야 합니다.</p><p style='margin-top:0cm;margin-right:0cm;margin-bottom:8.0pt;margin-left:0cm;text-align:justify;text-justify:inter-ideograph;line-height:107%;text-autospace:none;word-break:break-hangul;font-size:10.0pt;'>&nbsp; ※ 위의"
                + "나목 및 다목의 사항을 위반하여 발생한 사고·재해의 책임은 고객에게 있으므로 소비자보장책임보험의 혜택을"
                + "받을 수 없습니다.</p><p style='margin-top:0cm;margin-right:0cm;margin-bottom:8.0pt;margin-left:0cm;text-align:justify;text-justify:inter-ideograph;line-height:107%;text-autospace:none;word-break:break-hangul;font-size:10.0pt;'>&nbsp; ※ 고객의"
                + "과실로 발생한 사고로 인한 고객의 재산피해에 대해서는 과실상계원칙에 따라 보험금액을 감하여 지급합니다.</p><p style='margin-top:0cm;margin-right:0cm;margin-bottom:8.0pt;margin-left:0cm;text-align:justify;text-justify:inter-ideograph;line-height:107%;text-autospace:none;word-break:break-hangul;font-size:10.0pt;'>&nbsp; ※ 법령에"
                + "따른 보험가입대상인 소비자에 대해서는 소비자보장책임보험을 적용하지 않습니다.</p><p style='margin-top:0cm;margin-right:0cm;margin-bottom:8.0pt;margin-left:0cm;text-align:justify;text-justify:inter-ideograph;line-height:107%;text-autospace:none;word-break:break-hangul;font-size:10.0pt;'>&nbsp;2. 당사(점)의 안전책임</p><p style='margin-top:0cm;margin-right:0cm;margin-bottom:8.0pt;margin-left:0cm;text-align:justify;text-justify:inter-ideograph;line-height:107%;text-autospace:none;word-break:break-hangul;font-size:10.0pt;'>&nbsp; 가. 당사(점)가 유지·관리하는 공급설비의 결함으로 발생한 재해에 대해서는 당사(점)가 책임을 지고, 이를 위해 당사(점)는 소비자보장책임보험에 가입해야 합니다.</p><p style='margin-top:0cm;margin-right:0cm;margin-bottom:8.0pt;margin-left:0cm;text-align:justify;text-justify:inter-ideograph;line-height:107%;text-autospace:none;word-break:break-hangul;font-size:10.0pt;'>&nbsp; 나. 소비설비의 경우 당사(점)가"
                + "행하는 점검하자로 발생한 손해에 대해서는 당사(점)가 책임을"
                + "지고, 이를 위해&nbsp; 당사(점)는 소비자보장책임보험에 가입해야 합니다.</p><p style='margin-top:0cm;margin-right:0cm;margin-bottom:8.0pt;margin-left:0cm;text-align:justify;text-justify:inter-ideograph;line-height:107%;text-autospace:none;word-break:break-hangul;font-size:10.0pt;'>&nbsp; ※ 소비자보장책임보험의"
                + "보장 범위는 당사(점)가 계약체결 시 설명해 드립니다.</p>"
                + "</td>"
                + "</tr>"

                + "<tr>"
                + "<td style='border: 1px solid rgb(0, 0, 0); height: 20px;' >"
                + "<p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; '>소비자보장</p><p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; '>책임보험&nbsp;</p><p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; '>가입 확인</p>"
                + "</td>"
                + "<td style='border: 1px solid rgb(0, 0, 0); height: 20px;' colspan='6'>"
                + "<p style='margin-top:0cm;margin-right:0cm;margin-bottom:8.0pt;margin-left:0cm;text-align:justify;text-justify:inter-ideograph;line-height:107%;text-autospace:none;word-break:break-hangul;font-size:10.0pt;'>&nbsp; 당사(점)는 가스사고를 대비하여 소비자보장책임보험에 가입하였고, 가스사용 중 불의의 가스사고로 피해가 발생한 경우에는 고객은 사망(후유장애"
                + "포함)의 경우 1명당 8천만원, 부상의 경우 1명당 1천5백만원, 재산피해의 경우 3억원의"
                + "범위에서 피해보상을 받으실 수 있습니다. 다만, 소비자의"
                + "고의적인 사고(보험약관에 보상하도록 적혀 있는 경우는 제외합니다) 또는"
                + "계약서상의 기본적 준수사항 위반과 천재지변의 경우에는 보상이 이루어지지 않습니다.</p><p style='font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'><span style='font-size:10.0pt;line-height:107%;mso-fareast-theme-font:minor-fareast;mso-fareast-language:KO;'>&nbsp;※ </span><span style='font-size:10.0pt;line-height:107%;mso-fareast-language:KO;'>법령에 따른 보험가입 대상인 소비자에게는 소비자보장책임보험을 적용하지 않습니다</span></p>"
                + "</td>"
                + "</tr>"

                + "<tr>"
                + "<td style='border: 1px solid rgb(0, 0, 0); height: 20px;' >"
                + "<p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; '>긴급 시&nbsp;</p><p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; '>연락처</p>"
                + "</td>"
                + "<td style='border: 1px solid rgb(0, 0, 0); height: 20px;' colspan='6'>"
                + "<p style='margin-top:0cm;margin-right:0cm;margin-bottom:8.0pt;margin-left:0cm;text-align:justify;text-justify:inter-ideograph;line-height:107%;text-autospace:none;word-break:break-hangul;font-size:10.0pt;'>&nbsp;1. 당사(점)는 재해가 발생하거나 발생할 우려가 있을 경우에 대비해 24시간 체제를 유지해야 하고, 고객은 긴급 시 아래의 연락처로 전화하여"
                + "주시기 바랍니다.</p><p style='margin-top:0cm;margin-right:0cm;margin-bottom:8.0pt;margin-left:0cm;text-align:justify;text-justify:inter-ideograph;line-height:107%;text-autospace:none;word-break:break-hangul;font-size:10.0pt;'>&nbsp;2. 긴급"
                + "시에는 다음의 조치를 하여 주시기 바랍니다.</p><p style='margin-top:0cm;margin-right:0cm;margin-bottom:8.0pt;margin-left:0cm;text-align:justify;text-justify:inter-ideograph;line-height:107%;text-autospace:none;word-break:break-hangul;font-size:10.0pt;'>&nbsp; 가. 화재발생 시</p><p style='margin-top:0cm;margin-right:0cm;margin-bottom:8.0pt;margin-left:0cm;text-align:justify;text-justify:inter-ideograph;line-height:107%;text-autospace:none;word-break:break-hangul;font-size:10.0pt;'>&nbsp;&nbsp;&nbsp;&nbsp; 용기의"
                + "밸브를 잠그고(오른쪽으로 돌리면 잠김), 소방서 등 관계자에게"
                + "용기의 위치를 알린 후 당사(점)에 연락해 주시기 바랍니다.</p><p style='margin-top:0cm;margin-right:0cm;margin-bottom:8.0pt;margin-left:0cm;text-align:justify;text-justify:inter-ideograph;line-height:107%;text-autospace:none;word-break:break-hangul;font-size:10.0pt;'>&nbsp; 나. 수해의 위험이 있는 경우</p><p style='margin-top:0cm;margin-right:0cm;margin-bottom:8.0pt;margin-left:0cm;text-align:justify;text-justify:inter-ideograph;line-height:107%;text-autospace:none;word-break:break-hangul;font-size:10.0pt;'>&nbsp;&nbsp;&nbsp;"
                + "(1) 용기 등이 떠내려가지 않도록 하여 주시기 바랍니다.</p><p style='margin-top:0cm;margin-right:0cm;margin-bottom:8.0pt;margin-left:0cm;text-align:justify;text-justify:inter-ideograph;line-height:107%;text-autospace:none;word-break:break-hangul;font-size:10.0pt;'>&nbsp;&nbsp;&nbsp;"
                + "(2) 용기, 조정기 등이 침수된 경우에는 당사(점)의 점검을 받은 후 사용하시기 바랍니다.</p>"
                + "</td>"
                + "</tr>"

                + "<tr>"
                + "<td style='border: 1px solid rgb(0, 0, 0); height: 20px;' >"
                + "<p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 1; font-size: 10pt; '>소비자</p><p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 1; font-size: 10pt; '>불편신고</p>"
                + "</td>"
                + "<td style='border: 1px solid rgb(0, 0, 0); height: 20px;' colspan='6'>"
                + "<p style='margin-top:0cm;margin-right:0cm;margin-bottom:8.0pt;margin-left:0cm;text-align:justify;text-justify:inter-ideograph;line-height:107%;text-autospace:none;word-break:break-hangul;font-size:10.0pt;'>&nbsp;부당요금"
                + "징수, 가스공급 지연, 서비스 불이행 등 소비자불편사항이"
                + "발생한 경우에는 소비자불만신고센터로 전화하여 주시기 바랍니다.</p>"
                + "</td>"
                + "</tr>"
                + "</table>"
                + "<img src='" + " />"


                + "</body>"
                + "</html>";

        return htmlContent;

    }


    public String AnContfile(){
        String htmlContent ="\n"
                + "<p style='text-align: justify; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; font-family: Noto Sans KR;'><b style='font-size: 10pt; text-align: justify;'>&nbsp;[별지 3의2]&nbsp;</b><span style='font-size: 10pt; text-align: justify; font-family: Noto Sans KR;'>&lt;개정 2022.1.21.&gt;&nbsp;</span></p>\n"
                + " <table border='1' cellspacing='0' cellpadding='0' style='word-break: normal; font-size: 10pt; width: 887px; border: 1px none rgb(0, 0, 0); border-collapse: collapse; height: 1256.69px;'>\n"
                + "<tbody>\n"
                + "<tr>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 883px; height: 36px;' colspan='4'>\n"
                + "<p style='margin: 0cm 0cm 8pt; line-height: 1; font-size: 10pt; font-family: Noto Sans KR; text-align: justify;'><b style='font-size: 10pt;'>&nbsp;</b><span style='font-size: 10pt; font-family: Noto Sans KR;'>[액법 시행규칙 별지 제50호서식]</span></p><p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; font-family: Noto Sans KR;'><b style='font-size: 16pt;'>액화석유가스 안전공급계약서</b><b style='font-size: 10pt;'></b></p><p style='margin: 0cm 0cm 8pt; line-height: 107%; font-size: 10pt; font-family: Noto Sans KR; text-align: justify;'><b style='font-size: 10pt;'>&nbsp;</b><span style='font-size: 10pt; font-family: Noto Sans KR;'>※ [&nbsp;\n"
                + "]에는 해당되는 곳에 √표를 합니다.&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;(앞쪽)</span></p>\n"
                + "</td>\n"
                + "</tr>\n"
                + "<tr>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 883px; height: 10px;' colspan='4'>\n"
                + "<p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 1; font-size: 10pt; font-family: Noto Sans KR;'><span style='font-size: 10pt; font-family: Noto Sans KR;'>&nbsp; 「액화석유가스의 안전관리 및 사업법 시행규칙」 별표 13 제3호가목에 따라 당사(점)[이하 '당사(점)'이라\n"
                + "합니다]</span></p><p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 1; font-size: 10pt; font-family: Noto Sans KR;'><span style='font-size: 10pt; font-family: Noto Sans KR;'>는 고객(이하\n"
                + "'고객'이라 합니다)과 액화석유가스의\n"
                + "안전공급에 관하여 다음과 같이 계약을 체결합니다.</span></p>\n"
                + "</td>\n"
                + "</tr>\n"
                + "<tr>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 88px; height: 23px;'>\n"
                + "<p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; font-family: Noto Sans KR;'><span style='font-size: 10pt; font-family: Noto Sans KR;'>가스의</span></p><p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; font-family: Noto Sans KR;'><span style='font-size: 10pt; font-family: Noto Sans KR;'>전달방법</span></p>\n"
                + "</td>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 795px; height: 23px;' colspan='3'>\n"
                + "<p style='margin: 0cm 0cm 8pt; line-height: 1.2; font-size: 10pt; font-family: Noto Sans KR; text-align: justify;'><b style='font-size: 10pt;'>&nbsp; &nbsp;</b><span style='font-size: 10pt; font-family: Noto Sans KR;'>&nbsp; 당사(점)는 액화석유가스(LPG)가\n"
                + "충전된 용기를 가스사용에 지장이 없도록, 계획된 배달날짜 또는 고객이 주문할</span><b style='font-size: 10pt;'>&nbsp;</b><span style='font-size: 10pt; font-family: Noto Sans KR;'>때마다 신속히 배달하겠으며, 사용시설에 직접 연결하여 드립니다. 다만, 체적으로 판매할 경우에는 사용 중인&nbsp;</span><span style='font-size: 10pt; font-family: Noto Sans KR;'>용기 안에 있는 가스가 떨어지면 자동적으로 다른 용기에서 가스가 공급될\n"
                + "수 있도록 항상 충전된 예비용기를&nbsp;</span><span style='font-size: 10pt; font-family: Noto Sans KR;'>연결하여 드리겠습니다.</span></p>\n"
                + "</td>\n"
                + "</tr>\n"

                + "<tr>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 88px; height: 156.482px;'>\n"
                + "<p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; font-family: Noto Sans KR;'><span style='font-size: 10pt; font-family: Noto Sans KR;'>가스의</span></p><p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; font-family: Noto Sans KR;'><span style='font-size: 10pt; font-family: Noto Sans KR;'>계량방법과&nbsp;</span></p><p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; font-family: Noto Sans KR;'><span style='font-size: 10pt; font-family: Noto Sans KR;'>가스요금</span></p>\n"
                + "</td>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 795px; height: 156.482px;' colspan='3'>\n"
                + "<p style='margin: 0cm 0cm 8pt; line-height: 1; font-size: 10pt; font-family: Noto Sans KR; text-align: justify;'><span style='font-size: 10pt; font-family: Noto Sans KR;'><b>&nbsp;&nbsp;</b>1. 체적(계량기로 계량함)으로 판매할 경우</span></p><p style='margin: 0cm 0cm 8pt; line-height: 1; font-size: 10pt; font-family: Noto Sans KR; text-align: justify;'><span style='font-size: 10pt; font-family: Noto Sans KR;'><b>&nbsp; &nbsp;&nbsp;</b>가. 매월 가스사용량을 검침하여 별첨의 &lt;체적판매 가스요금표&gt;에 따라 계산된 가스요금을 받으며, 만약&nbsp;</span><span style='font-size: 10pt; font-family: Noto Sans KR;'>가스계량기의 고장 등으로\n"
                + "계량이 잘 되지 않은 경우에는 최근 3개월간 검침된 양의 평균수치를 기준으로 하여</span><b style='font-size: 10pt;'>&nbsp;</b><span style='font-size: 10pt; font-family: Noto Sans KR;'>가스요금을 계산합니다.</span></p><p style='margin: 0cm 0cm 8pt; line-height: 1; font-size: 10pt; font-family: Noto Sans KR; text-align: justify;'><span style='font-size: 10pt; font-family: Noto Sans KR;'><b>&nbsp; &nbsp;&nbsp;</b>나. 가스요금의 가격구성과 요금체계의 설명은 가스요금표에 적혀 있고, 가스요금을\n"
                + "조정한 경우에는 조정된</span><b style='font-size: 10pt;'>&nbsp;</b><span style='font-size: 10pt; font-family: Noto Sans KR;'>가스요금을 적용하기 전에 알려드리겠습니다.</span></p><p style='margin: 0cm 0cm 8pt; line-height: 1; font-size: 10pt; font-family: Noto Sans KR; text-align: justify;'><span style='font-size: 10pt; font-family: Noto Sans KR;'><b>&nbsp;&nbsp;</b>2. 중량으로\n"
                + "판매할 경우</span></p><p style='margin: 0cm 0cm 8pt; line-height: 1; font-size: 10pt; font-family: Noto Sans KR; text-align: justify;'><b style='font-size: 10pt;'>&nbsp;</b><span style='font-size: 10pt; font-family: Noto Sans KR;'>&nbsp;&nbsp; 정량표시를\n"
                + "한 용기로 배달하고, 별첨의 &lt;중량판매 가스요금표&gt;에 따라 가스요금을 받으며, 가스요금을&nbsp;</span><span style='font-size: 10pt; font-family: Noto Sans KR;'>조정한 경우에는 조정된\n"
                + "가스요금을 적용하기 전에 알려드리겠습니다.</span></p><p style='margin: 0cm 0cm 8pt; line-height: 1; font-size: 10pt; font-family: Noto Sans KR; text-align: justify;'><span style='font-size: 10pt; font-family: Noto Sans KR;'><b>&nbsp;&nbsp;</b>3. 가스요금이\n"
                + "납기 내에 납부되지 않은 경우 당사(점)는 고객에게 납기\n"
                + "경과분에 대해 관할 허가관청이&nbsp;</span><span style='font-size: 10pt; font-family: Noto Sans KR;'>인정하는 연체료(가산금)를\n"
                + "부과할 수 있고, 사전 연락 후 가스공급을 중지할 수 있습니다.</span></p><p style='margin: 0cm 0cm 8pt; line-height: 1; font-size: 10pt; font-family: Noto Sans KR; text-align: justify;'><b style='font-size: 10pt;'>&nbsp; &nbsp;</b><span style='font-size: 10pt; font-family: Noto Sans KR;'>&nbsp; ※ 별첨: 체적(중량)판매 가스요금표 1부</span></p>\n"
                + "</td>\n"
                + "</tr>\n"

                + "<tr>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 88px; height: 124.323px;'>\n"
                + "<p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; font-family: Noto Sans KR;'><span style='font-size: 10pt; font-family: Noto Sans KR;'>공급설비와&nbsp;</span></p><p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; font-family: Noto Sans KR;'><span style='font-size: 10pt; font-family: Noto Sans KR;'>소비설비에&nbsp;</span></p><p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; font-family: Noto Sans KR;'><span style='font-size: 10pt; font-family: Noto Sans KR;'>대한&nbsp;</span></p><p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; font-family: Noto Sans KR;'><span style='font-size: 10pt; font-family: Noto Sans KR;'>비용부담 등</span></p>\n"
                + "</td>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 795px; height: 124.323px;' colspan='3'>\n"
                + "<p style='margin: 0cm 0cm 8pt; line-height: 107%; font-size: 10pt; font-family: Noto Sans KR; text-align: justify;'><span style='font-size: 10pt; font-family: Noto Sans KR;'>&nbsp;1. 공급설비와\n"
                + "소비설비의 설치·변경 등의 비용부담방법은 다음과 같습니다.</span></p><p style='margin: 0cm 0cm 8pt; line-height: 107%; font-size: 10pt; font-family: Noto Sans KR; text-align: justify;'><span style='font-size: 10pt; font-family: Noto Sans KR;'>&nbsp; 가. 당사(점) 소유의 공급설비(체적판매의 경우 용기 출구에서 계량기 출구까지의 설비를 말합니다)를\n"
                + "사용하여 고객이 당사(점)으로부터 가스를 공급받는 경우 그\n"
                + "설비의 사용에 대해 별도의 사용료를 부과하지 않습니다. 다만, 고객의\n"
                + "요청으로 계약기간을 정하지 않는 경우에는 당사(점)은 그\n"
                + "사용료를 부과할 수 있고, 고객의 사정(건물 보수 등)으로 공급설비의 변경·교환·수리\n"
                + "등이 필요한 경우에는 고객이 부담합니다.</span></p><p style='margin: 0cm 0cm 8pt; line-height: 107%; font-size: 10pt; font-family: Noto Sans KR; text-align: justify;'><span style='font-size: 10pt; font-family: Noto Sans KR;'>&nbsp; 나. 소비설비(체적판매의 경우 계량기 출구에서 연소기까지의 설비를 말하고, 중량판매의 경우 용기 출구에서 연소기까지의 설비를 말합니다)의 설치·변경 등은 고객이 부담합니다.</span></p><p style='margin: 0cm 0cm 8pt; line-height: 107%; font-size: 10pt; font-family: Noto Sans KR; text-align: justify;'><span style='font-size: 10pt; font-family: Noto Sans KR;'>&nbsp;2. 고객은\n"
                + "당사(점) 소유의 설비로 다른 가스공급자로부터 가스를 공급받을\n"
                + "수 없습니다.</span></p>\n"
                + "</td>\n"
                + "</tr>\n"
                + "<tr>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 88px; height: 10px;'>\n"
                + "<p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; font-family: Noto Sans KR;'><span style='font-size: 10pt; font-family: Noto Sans KR;'>계약기간</span></p>\n"
                + "</td>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 795px; height: 10px;' colspan='3'>\n"
                + "<p style='margin: 0cm 0cm 8pt; line-height: 107%; font-size: 10pt; font-family: Noto Sans KR; text-align: justify;'><span style='font-size: 10pt; font-family: Noto Sans KR;'>&nbsp; 이\n"
                + "계약의 유효기간은&nbsp; &nbsp; &nbsp;&nbsp; 년&nbsp;&nbsp;&nbsp; 월&nbsp; &nbsp; 일부터&nbsp; &nbsp;&nbsp;&nbsp;&nbsp; 년&nbsp; &nbsp; 월&nbsp; &nbsp; 일까지로 하고, 당사(점)은 계약만료일 15일\n"
                + "전에 고객에게 계약만료를 알리며, 고객이 계약만료일 전에 계약해지를 알리지 않은 경우 계약기간은 6개월씩 연장됩니다.</span></p><p style='margin: 0cm 0cm 8pt; line-height: 107%; font-size: 10pt; font-family: Noto Sans KR; text-align: justify;'><span style='font-size: 10pt; font-family: Noto Sans KR;'>&nbsp;※ 계약기간: 체적판매방법으로 공급하는 경우 및 중량판매방법(용기집합설비를 설치한\n"
                + "주택에 공급하는 경우에만을 말합니다)으로 공급하는 경우로서 공급설비를 당사(점)의 부담으로 설치한 경우 당사(점)와 체결하는 최초의 안전공급계약은 1년(주택의 경우에는 2년) 이상으로\n"
                + "하고, 공급설비와 소비설비 모두를 당사(점)의 부담으로 설치한 경우 당사(점)와\n"
                + "체결하는 최초의 안전공급계약은 2년(주택의 경우에는 3년) 이상으로 합니다.&nbsp;</span></p>\n"
                + "</td>\n"
                + "</tr>\n"
                + "<tr>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 88px; height: 256.141px;'>\n"
                + "<p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; font-family: Noto Sans KR;'><span style='font-size: 10pt; font-family: Noto Sans KR;'>계약의 해지</span></p>\n"
                + "</td>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 795px; height: 256.141px;' colspan='3'>\n"
                + "<p style='margin: 0cm 0cm 8pt; line-height: 1; font-size: 10pt; font-family: Noto Sans KR; text-align: justify;'><span style='font-size: 10pt; font-family: Noto Sans KR;'>&nbsp; 고객이\n"
                + "당사(점)와 계약한 안전공급계약의 해지를 요청할 경우 당사(점)는 5일 이내에 고객과\n"
                + "가스요금 등을 정산 및 납부하고 계약을 해지하여야 하며, 다음의 방법에 따라야 합니다.</span></p><p style='margin: 0cm 0cm 8pt; line-height: 1; font-size: 10pt; font-family: Noto Sans KR; text-align: justify;'><span style='font-size: 10pt; font-family: Noto Sans KR;'>&nbsp;1. 계약기간이\n"
                + "만료되어 고객이 계약해지를 요구하는 경우 당사(점)는 그\n"
                + "설비를 철거하거나 고객이 원하는 새로운 가스공급자에게 양도·양수합니다.</span></p><p style='margin: 0cm 0cm 8pt; line-height: 1; font-size: 10pt; font-family: Noto Sans KR; text-align: justify;'><span style='font-size: 10pt; font-family: Noto Sans KR;'>&nbsp;2. 계약기간\n"
                + "내에 당사(점)이 무단으로 가스공급의 중단, 사전 협의 없는 요금의 인상, 안전점검 미실시, 그 밖에 안전관리 업무를 하지 않은 경우로서 고객이 그 설비의 철거를 원할 경우 당사(점)은 그 설비를 철거합니다.</span></p><p style='margin: 0cm 0cm 8pt; line-height: 1; font-size: 10pt; font-family: Noto Sans KR; text-align: justify;'><span style='font-size: 10pt; font-family: Noto Sans KR;'>&nbsp;3. 제2호 외의 사유로 계약기간 내에 고객이 계약해지를 요청하는 경우 고객은 당사(점)가 설치한 설비에 대하여 철거비용을 부담해야 합니다. 다만, 고객이 그 설비의 철거를 원하지 않고 새로운 가스공급자가 있는 경우 당사(점)는 제1호의 방법으로 할 수 있습니다.</span></p><p style='margin: 0cm 0cm 8pt; line-height: 1; font-size: 10pt; font-family: Noto Sans KR; text-align: justify;'><span style='font-size: 10pt; font-family: Noto Sans KR;'>&nbsp;4. 공급설비가\n"
                + "고객의 소유인 경우 당사(점)이 구매·철거합니다. 다만, 고객이\n"
                + "공급설비의 철거를 원하지 않는 경우에는 당사(점)은 용기만\n"
                + "구매·철거하고, 새로운 가스공급자는 고객의 공급설비를 구매해야\n"
                + "합니다.</span></p><p style='margin: 0cm 0cm 8pt; line-height: 1; font-size: 10pt; font-family: Noto Sans KR; text-align: justify;'><span style='font-size: 10pt; font-family: Noto Sans KR;'>&nbsp;5. 당사(점)의 귀책사유 없이 고객이 계약을 해지하려면 고객은 다음의 방법에\n"
                + "따라 산정한 철거비용 등을 당사(점)에 납부하여야 합니다.</span></p><p style='margin: 0cm 0cm 8pt; line-height: 1; font-size: 10pt; font-family: Noto Sans KR; text-align: justify;'><span style='font-size: 10pt; font-family: Noto Sans KR;'>&nbsp; 가. 당사(점)이 설치한 설비의\n"
                + "철거비용: 통계청의 건설임금단가(배관공)를 적용</span></p><p style='margin: 0cm 0cm 8pt; line-height: 1; font-size: 10pt; font-family: Noto Sans KR; text-align: justify;'><span style='font-size: 10pt; font-family: Noto Sans KR;'>&nbsp; 나. 소비설비[당사(점)의 부담으로 설치한 경우만 해당합니다]의 시가 상당액: 계약해지 당시의 신규제품가격(기획재정부장관이 정하는 기준에 적합한\n"
                + "전문가격조사기관으로서 기획재정부장관에게 등록한 기관이 조사하여 공표한 가격을 말합니다)에서 1년에 20%씩 뺀 금액</span></p><p style='margin: 0cm 0cm 8pt; line-height: 1; font-size: 10pt; font-family: Noto Sans KR; text-align: justify;'><span style='font-size: 10pt; font-family: Noto Sans KR;'>&nbsp;6. 계약기간이\n"
                + "지난 이후 당사(점)의 부담으로 설치한 소비설비는 계약서에\n"
                + "별도로 고객에게 소유권이 이전되는 것으로 명시한 경우에 한정하여 고객의 소유로 합니다.</span></p><p style='margin: 0cm 0cm 8pt; line-height: 1; font-size: 10pt; font-family: Noto Sans KR; text-align: justify;'><span style='font-size: 10pt; font-family: Noto Sans KR;'>&nbsp;7. 계약의\n"
                + "해지는 요금의 정산과 공급설비에 대한 보상시 발행한 영수증 등으로 확인할 수 있어야 합니다.&nbsp;</span></p>\n"
                + "</td>\n"
                + "</tr>\n"
                + "<tr>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 88px; height: 141.133px;'>\n"
                + "<p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; font-family: Noto Sans KR;'><span style='font-size: 10pt; font-family: Noto Sans KR;'>공급설비와&nbsp;</span></p><p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; font-family: Noto Sans KR;'><span style='font-size: 10pt; font-family: Noto Sans KR;'>소비설비의&nbsp;</span></p><p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; font-family: Noto Sans KR;'><span style='font-size: 10pt; font-family: Noto Sans KR;'>관리방법</span></p>\n"
                + "</td>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 795px; height: 141.133px;' colspan='3'>\n"
                + "<p style='margin: 0cm 0cm 8pt; line-height: 107%; font-size: 10pt; font-family: Noto Sans KR; text-align: justify;'><span style='font-size: 10pt; font-family: Noto Sans KR;'>&nbsp;1. 공급설비에\n"
                + "대해서는, 당사(점)가\n"
                + "법규에서 정하는 바에 따라 설비의 유지·관리를 위한 점검을 합니다.</span></p><p style='margin: 0cm 0cm 8pt; line-height: 107%; font-size: 10pt; font-family: Noto Sans KR; text-align: justify;'><span style='font-size: 10pt; font-family: Noto Sans KR;'>&nbsp;2. 소비설비에\n"
                + "대해서는, 당사(점)가\n"
                + "법규에서 정하는 바에 따라 점검을 실시하나, 일상의 관리는 「가스안전 계도물」등을 참고하여 관리하여\n"
                + "주시고, 고객은 당사(점)의\n"
                + "점검을 거부해서는 안 되며, 점검 결과 기준에 맞지 않거나 가스누출 등의 우려가 있을 경우 당사(점)는 안전상 가스사용을 일시 중단시킬 수 있으며, 중단조치 후 무단으로 가스를 사용하였을 경우 당사(점)는 그로 인한 책임을 지지 않습니다.</span></p><p style='margin: 0cm 0cm 8pt; line-height: 107%; font-size: 10pt; font-family: Noto Sans KR; text-align: justify;'><span style='font-size: 10pt; font-family: Noto Sans KR;'>&nbsp;3. 고객은\n"
                + "당사(점)의 시설개선 권고를 받은 경우 당사(점)가 정한 날까지 시설 개선을 해야 합니다. 시설 개선 권고를 이행하지 않는 경우 당사(점)는 그 사실을 관할관청에 알려야 합니다.</span></p><p style='margin: 0cm 0cm 8pt; line-height: 107%; font-size: 10pt; font-family: Noto Sans KR; text-align: justify;'><span style='font-size: 10pt; font-family: Noto Sans KR;'>&nbsp;4. 고객은\n"
                + "당사(점)와 사전 협의 없이 당사(점) 소유의 설비를 임의로 철거하거나 변경할 수 없습니다. 다만, 협의가 이루어지지 않아 고객이 당사(점) 소유 설비의 철거를 요청한 경우 5일 이내에 철거하겠습니다.</span></p><p style='margin: 0cm 0cm 8pt; line-height: 107%; font-size: 10pt; font-family: Noto Sans KR; text-align: justify;'><span style='font-size: 10pt; font-family: Noto Sans KR;'>&nbsp;5. 당사(점)는 고객이 관할관청의 수리 또는 개선명령을 이행하기 위하여 당사(점)에게 고객의 소비설비의 수리 또는 개선을 요청한 경우 2일 이내에 고객의 소비설비를 개선하여 드리겠습니다. 다만, 이에 필요한 비용은 고객이 부담합니다.</span></p>\n"
                + "</td>\n"
                + "</tr>\n"
                + "</tbody>\n"
                + "</table>\n"
                + "<p style='margin: 0cm 0cm 8pt; text-align: justify; line-height: 107%; font-size: 10pt; font-family: Noto Sans KR;'><span style='font-size: 10pt; font-family: Noto Sans KR;'>※ 고객과 관련된 정보는 다른 목적으로 사용하거나 누출할 수 없습니다.</span></p>\n";

                return htmlContent;
    }

    public String AnContfile2() {

        String htmlContent = "<p style='text-align: left; font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; (뒷면)</p>\n"
                + "<table border='1' cellspacing='0' cellpadding='0' style='word-break: normal; font-size: 10pt; width: 885px; border: 1px none rgb(0, 0, 0); border-collapse: collapse; height: 1080.1px;'>\n"
                + "<tbody>\n"
                + "<tr>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 73px; height: 20px;'>\n"
                + "<p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 1; font-size: 10pt; font-family: &quot;맑은 고딕&quot;;'>가스안전</p><p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 1; font-size: 10pt; font-family: &quot;맑은 고딕&quot;;'>계도물</p>\n"
                + "</td>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 804px; height: 20px;' colspan='8'>\n"
                + "<p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'>&nbsp;&nbsp;<span style='font-family: &quot;맑은 고딕&quot;; font-size: 10pt; text-align: justify;'>당사</span><span style='font-family: &quot;맑은 고딕&quot;; font-size: 10pt; text-align: justify;'>(</span><span style='font-family: &quot;맑은 고딕&quot;; font-size: 10pt; text-align: justify;'>점</span><span style='font-family: &quot;맑은 고딕&quot;; font-size: 10pt; text-align: justify;'>)</span><span style='font-family: &quot;맑은 고딕&quot;; font-size: 10pt; text-align: justify;'>는 액화석유가스의\n"
                + "안전사용을 위한 주의사항을 적은 서면을</span><span style='font-family: &quot;맑은 고딕&quot;; font-size: 10pt; text-align: justify;'> 6</span><span style='font-family: &quot;맑은 고딕&quot;; font-size: 10pt; text-align: justify;'>개월에</span><span style='font-family: &quot;맑은 고딕&quot;; font-size: 10pt; text-align: justify;'> 1</span><span style='font-family: &quot;맑은 고딕&quot;; font-size: 10pt; text-align: justify;'>회 이상\n"
                + "전달하겠으며</span><span style='font-family: &quot;맑은 고딕&quot;; font-size: 10pt; text-align: justify;'>, </span><span style='font-family: &quot;맑은 고딕&quot;; font-size: 10pt; text-align: justify;'>고객은 반드시 그 내용을 확인하고</span><span style='font-family: &quot;맑은 고딕&quot;; font-size: 10pt; text-align: justify;'>, </span><span style='font-family: &quot;맑은 고딕&quot;; font-size: 10pt; text-align: justify;'>가스를\n"
                + "안전하게 사용하시기 바랍니다</span><span style='font-family: &quot;맑은 고딕&quot;; font-size: 10pt; text-align: justify;'>.</span></p>\n"
                + "</td>\n"
                + "</tr>\n"
                + "<tr>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 73px; height: 285.844px;'>\n"
                + "<p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; font-family: &quot;맑은 고딕&quot;;'>안전책임에&nbsp;</p><p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; font-family: &quot;맑은 고딕&quot;;'>관한 사항</p>\n"
                + "</td>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 804px; height: 285.844px;' colspan='8'>\n"
                + "<p style='margin-top:0cm;margin-right:0cm;margin-bottom:8.0pt;margin-left:0cm;text-align:justify;text-justify:inter-ideograph;line-height:107%;text-autospace:none;word-break:break-hangul;font-size:10.0pt;font-family:&quot;맑은 고딕&quot;;'>&nbsp;1. 고객의\n"
                + "안전책임</p><p style='margin-top:0cm;margin-right:0cm;margin-bottom:8.0pt;margin-left:0cm;text-align:justify;text-justify:inter-ideograph;line-height:107%;text-autospace:none;word-break:break-hangul;font-size:10.0pt;font-family:&quot;맑은 고딕&quot;;'>&nbsp; 가. 고객은 가스를 사용할 때 이 계약서와 가스안전 계도물에 적힌 안전에 관한 주의사항을 준수해야 합니다.</p><p style='margin-top:0cm;margin-right:0cm;margin-bottom:8.0pt;margin-left:0cm;text-align:justify;text-justify:inter-ideograph;line-height:107%;text-autospace:none;word-break:break-hangul;font-size:10.0pt;font-family:&quot;맑은 고딕&quot;;'>&nbsp; 나. 고객은 당사(점)와 사전\n"
                + "협의 없이 당사(점) 소유의 설비를 임의로 철거하거나 변경하지\n"
                + "말아야 합니다.</p><p style='margin-top:0cm;margin-right:0cm;margin-bottom:8.0pt;margin-left:0cm;text-align:justify;text-justify:inter-ideograph;line-height:107%;text-autospace:none;word-break:break-hangul;font-size:10.0pt;font-family:&quot;맑은 고딕&quot;;'>&nbsp; 다. 당사(점)의 점검 결과\n"
                + "부적합한 것으로 지적·통지된 사항은 안전을 위하여 신속히 조치하여야 합니다.</p><p style='margin-top:0cm;margin-right:0cm;margin-bottom:8.0pt;margin-left:0cm;text-align:justify;text-justify:inter-ideograph;line-height:107%;text-autospace:none;word-break:break-hangul;font-size:10.0pt;font-family:&quot;맑은 고딕&quot;;'>&nbsp; ※ 위의\n"
                + "나목 및 다목의 사항을 위반하여 발생한 사고·재해의 책임은 고객에게 있으므로 소비자보장책임보험의 혜택을\n"
                + "받을 수 없습니다.</p><p style='margin-top:0cm;margin-right:0cm;margin-bottom:8.0pt;margin-left:0cm;text-align:justify;text-justify:inter-ideograph;line-height:107%;text-autospace:none;word-break:break-hangul;font-size:10.0pt;font-family:&quot;맑은 고딕&quot;;'>&nbsp; ※ 고객의\n"
                + "과실로 발생한 사고로 인한 고객의 재산피해에 대해서는 과실상계원칙에 따라 보험금액을 감하여 지급합니다.</p><p style='margin-top:0cm;margin-right:0cm;margin-bottom:8.0pt;margin-left:0cm;text-align:justify;text-justify:inter-ideograph;line-height:107%;text-autospace:none;word-break:break-hangul;font-size:10.0pt;font-family:&quot;맑은 고딕&quot;;'>&nbsp; ※ 법령에\n"
                + "따른 보험가입대상인 소비자에 대해서는 소비자보장책임보험을 적용하지 않습니다.</p><p style='margin-top:0cm;margin-right:0cm;margin-bottom:8.0pt;margin-left:0cm;text-align:justify;text-justify:inter-ideograph;line-height:107%;text-autospace:none;word-break:break-hangul;font-size:10.0pt;font-family:&quot;맑은 고딕&quot;;'>&nbsp;2. 당사(점)의 안전책임</p><p style='margin-top:0cm;margin-right:0cm;margin-bottom:8.0pt;margin-left:0cm;text-align:justify;text-justify:inter-ideograph;line-height:107%;text-autospace:none;word-break:break-hangul;font-size:10.0pt;font-family:&quot;맑은 고딕&quot;;'>&nbsp; 가. 당사(점)가 유지·관리하는 공급설비의 결함으로 발생한 재해에 대해서는 당사(점)가 책임을 지고, 이를 위해 당사(점)는 소비자보장책임보험에 가입해야 합니다.</p><p style='margin-top:0cm;margin-right:0cm;margin-bottom:8.0pt;margin-left:0cm;text-align:justify;text-justify:inter-ideograph;line-height:107%;text-autospace:none;word-break:break-hangul;font-size:10.0pt;font-family:&quot;맑은 고딕&quot;;'>&nbsp; 나. 소비설비의 경우 당사(점)가\n"
                + "행하는 점검하자로 발생한 손해에 대해서는 당사(점)가 책임을\n"
                + "지고, 이를 위해&nbsp; 당사(점)는 소비자보장책임보험에 가입해야 합니다.</p><p style='margin-top:0cm;margin-right:0cm;margin-bottom:8.0pt;margin-left:0cm;text-align:justify;text-justify:inter-ideograph;line-height:107%;text-autospace:none;word-break:break-hangul;font-size:10.0pt;font-family:&quot;맑은 고딕&quot;;'>&nbsp; ※ 소비자보장책임보험의\n"
                + "보장 범위는 당사(점)가 계약체결 시 설명해 드립니다.</p>\n"
                + "</td>\n"
                + "</tr>\n"
                + "<tr>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 73px; height: 20px;'>\n"
                + "<p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; font-family: &quot;맑은 고딕&quot;;'>소비자보장</p><p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; font-family: &quot;맑은 고딕&quot;;'>책임보험&nbsp;</p><p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; font-family: &quot;맑은 고딕&quot;;'>가입 확인</p>\n"
                + "</td>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 804px; height: 20px;' colspan='8'>\n"
                + "<p style='margin-top:0cm;margin-right:0cm;margin-bottom:8.0pt;margin-left:0cm;text-align:justify;text-justify:inter-ideograph;line-height:107%;text-autospace:none;word-break:break-hangul;font-size:10.0pt;font-family:&quot;맑은 고딕&quot;;'>&nbsp; 당사(점)는 가스사고를 대비하여 소비자보장책임보험에 가입하였고, 가스사용 중 불의의 가스사고로 피해가 발생한 경우에는 고객은 사망(후유장애\n"
                + "포함)의 경우 1명당 8천만원, 부상의 경우 1명당 1천5백만원, 재산피해의 경우 3억원의\n"
                + "범위에서 피해보상을 받으실 수 있습니다. 다만, 소비자의\n"
                + "고의적인 사고(보험약관에 보상하도록 적혀 있는 경우는 제외합니다) 또는\n"
                + "계약서상의 기본적 준수사항 위반과 천재지변의 경우에는 보상이 이루어지지 않습니다.</p><p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'><span style='font-size:10.0pt;line-height:107%;font-family:&quot;맑은 고딕&quot;;mso-fareast-theme-font:minor-fareast;mso-fareast-language:KO;'>&nbsp;※ </span><span style='font-size:10.0pt;line-height:107%;font-family:&quot;맑은 고딕&quot;;mso-fareast-language:KO;'>법령에 따른 보험가입 대상인 소비자에게는 소비자보장책임보험을 적용하지 않습니다</span></p>\n"
                + "</td>\n"
                + "</tr>\n"
                + "<tr>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 73px; height: 20px;'>\n"
                + "<p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; font-family: &quot;맑은 고딕&quot;;'>긴급 시&nbsp;</p><p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; font-family: &quot;맑은 고딕&quot;;'>연락처</p>\n"
                + "</td>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 804px; height: 20px;' colspan='8'>\n"
                + "<p style='margin-top:0cm;margin-right:0cm;margin-bottom:8.0pt;margin-left:0cm;text-align:justify;text-justify:inter-ideograph;line-height:107%;text-autospace:none;word-break:break-hangul;font-size:10.0pt;font-family:&quot;맑은 고딕&quot;;'>&nbsp;1. 당사(점)는 재해가 발생하거나 발생할 우려가 있을 경우에 대비해 24시간 체제를 유지해야 하고, 고객은 긴급 시 아래의 연락처로 전화하여\n"
                + "주시기 바랍니다.</p><p style='margin-top:0cm;margin-right:0cm;margin-bottom:8.0pt;margin-left:0cm;text-align:justify;text-justify:inter-ideograph;line-height:107%;text-autospace:none;word-break:break-hangul;font-size:10.0pt;font-family:&quot;맑은 고딕&quot;;'>&nbsp;2. 긴급\n"
                + "시에는 다음의 조치를 하여 주시기 바랍니다.</p><p style='margin-top:0cm;margin-right:0cm;margin-bottom:8.0pt;margin-left:0cm;text-align:justify;text-justify:inter-ideograph;line-height:107%;text-autospace:none;word-break:break-hangul;font-size:10.0pt;font-family:&quot;맑은 고딕&quot;;'>&nbsp; 가. 화재발생 시</p><p style='margin-top:0cm;margin-right:0cm;margin-bottom:8.0pt;margin-left:0cm;text-align:justify;text-justify:inter-ideograph;line-height:107%;text-autospace:none;word-break:break-hangul;font-size:10.0pt;font-family:&quot;맑은 고딕&quot;;'>&nbsp;&nbsp;&nbsp;&nbsp; 용기의\n"
                + "밸브를 잠그고(오른쪽으로 돌리면 잠김), 소방서 등 관계자에게\n"
                + "용기의 위치를 알린 후 당사(점)에 연락해 주시기 바랍니다.</p><p style='margin-top:0cm;margin-right:0cm;margin-bottom:8.0pt;margin-left:0cm;text-align:justify;text-justify:inter-ideograph;line-height:107%;text-autospace:none;word-break:break-hangul;font-size:10.0pt;font-family:&quot;맑은 고딕&quot;;'>&nbsp; 나. 수해의 위험이 있는 경우</p><p style='margin-top:0cm;margin-right:0cm;margin-bottom:8.0pt;margin-left:0cm;text-align:justify;text-justify:inter-ideograph;line-height:107%;text-autospace:none;word-break:break-hangul;font-size:10.0pt;font-family:&quot;맑은 고딕&quot;;'>&nbsp;&nbsp;&nbsp;\n"
                + "(1) 용기 등이 떠내려가지 않도록 하여 주시기 바랍니다.</p><p style='margin-top:0cm;margin-right:0cm;margin-bottom:8.0pt;margin-left:0cm;text-align:justify;text-justify:inter-ideograph;line-height:107%;text-autospace:none;word-break:break-hangul;font-size:10.0pt;font-family:&quot;맑은 고딕&quot;;'>&nbsp;&nbsp;&nbsp;\n"
                + "(2) 용기, 조정기 등이 침수된 경우에는 당사(점)의 점검을 받은 후 사용하시기 바랍니다.</p>\n"
                + "</td>\n"
                + "</tr>\n"
                + "<tr>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 73px; height: 20px;'>\n"
                + "<p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 1; font-size: 10pt; font-family: &quot;맑은 고딕&quot;;'>소비자</p><p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 1; font-size: 10pt; font-family: &quot;맑은 고딕&quot;;'>불편신고</p>\n"
                + "</td>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 804px; height: 20px;' colspan='8'>\n"
                + "<p style='margin-top:0cm;margin-right:0cm;margin-bottom:8.0pt;margin-left:0cm;text-align:justify;text-justify:inter-ideograph;line-height:107%;text-autospace:none;word-break:break-hangul;font-size:10.0pt;font-family:&quot;맑은 고딕&quot;;'>&nbsp;부당요금\n"
                + "징수, 가스공급 지연, 서비스 불이행 등 소비자불편사항이\n"
                + "발생한 경우에는 소비자불만신고센터로 전화하여 주시기 바랍니다.</p>\n"
                + "</td>\n"
                + "</tr>\n"
                + "<tr>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 877px; height: 208px;' colspan='9'>\n"
                + "<p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'><br></p>\n"
                + "</td>\n"
                + "</tr>\n"
                + "<tr>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 249px; height: 20px;' colspan='3'>\n"
                + "<p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; font-family: &quot;맑은 고딕&quot;;'>소비자불만신고센터</p>\n"
                + "</td>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 628px; height: 20px;' colspan='6'>\n"
                + "<p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; font-family: &quot;맑은 고딕&quot;;'>당사(점)의 소유·관리에 속하는 공급설비</p>\n"
                + "</td>\n"
                + "</tr>\n"
                + "<tr>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 118px; height: 20px;' colspan='2'>\n"
                + "<p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; font-family: &quot;맑은 고딕&quot;;'>기관명</p>\n"
                + "</td>\n"
                + "<td class='' style='border-width: 1px; border-style: solid; border-color: rgb(0, 0, 0); width: 131px; height: 20px;'>\n"
                + "<p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; font-family: &quot;맑은 고딕&quot;;'>전화번호</p>\n"
                + "</td>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 90px; height: 20px;'>\n"
                + "<p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; font-family: &quot;맑은 고딕&quot;;'>품명</p>\n"
                + "</td>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 88px; height: 20px;'>\n"
                + "<p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; font-family: &quot;맑은 고딕&quot;;'>수량</p>\n"
                + "</td>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 124px; height: 20px;'>\n"
                + "<p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; font-family: &quot;맑은 고딕&quot;;'>비고</p>\n"
                + "</td>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 98px; height: 20px;'>\n"
                + "<p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; font-family: &quot;맑은 고딕&quot;;'>품명</p>\n"
                + "</td>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 100px; height: 20px;'>\n"
                + "<p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; font-family: &quot;맑은 고딕&quot;;'>수량</p>\n"
                + "</td>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 128px; height: 20px;'>\n"
                + "<p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; font-family: &quot;맑은 고딕&quot;;'>비고</p>\n"
                + "</td>\n"
                + "</tr>\n"
                + "<tr>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 118px; height: 22px;' colspan='2'>\n"
                + "<p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; font-family: &quot;맑은 고딕&quot;;'>시·군·구청</p>\n"
                + "</td>\n"
                + "<td class='' style='border-width: 1px; border-style: solid; border-color: rgb(0, 0, 0); width: 131px; height: 22px;'>\n"
                + "<p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><br></p>\n"
                + "</td>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 90px; height: 22px;'>\n"
                + "<p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; font-family: &quot;맑은 고딕&quot;;'>용기</p>\n"
                + "</td>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 88px; height: 22px;'>\n"
                + "<p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><br></p>\n"
                + "</td>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 124px; height: 22px;'>\n"
                + "<p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><br></p>\n"
                + "</td>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 98px; height: 22px;'>\n"
                + "<p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; font-family: &quot;맑은 고딕&quot;;'>기화기</p>\n"
                + "</td>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 100px; height: 22px;'>\n"
                + "<p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><br></p>\n"
                + "</td>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 128px; height: 22px;'>\n"
                + "<p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><br></p>\n"
                + "</td>\n"
                + "</tr>\n"
                + "<tr>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 118px; height: 20px;' colspan='2'>\n"
                + "<p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; font-family: &quot;맑은 고딕&quot;;'>소비자단체</p>\n"
                + "</td>\n"
                + "<td class='' style='border-width: 1px; border-style: solid; border-color: rgb(0, 0, 0); width: 131px; height: 20px;'>\n"
                + "<p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><br></p>\n"
                + "</td>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 90px; height: 20px;'>\n"
                + "<p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><span style='font-size:10.0pt;line-height:107%;font-family:&quot;맑은 고딕&quot;;'>가스계량기</span></p>\n"
                + "</td>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 88px; height: 20px;'>\n"
                + "<p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><br></p>\n"
                + "</td>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 124px; height: 20px;'>\n"
                + "<p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><br></p>\n"
                + "</td>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 98px; height: 20px;'>\n"
                + "<p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><span style='font-size:10.0pt;line-height:107%;font-family:&quot;맑은 고딕&quot;;'>공급관</span></p>\n"
                + "</td>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 100px; height: 20px;'>\n"
                + "<p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><br></p>\n"
                + "</td>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 128px; height: 20px;'>\n"
                + "<p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><br></p>\n"
                + "</td>\n"
                + "</tr>\n"
                + "<tr>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 118px; height: 20px;' colspan='2'>\n"
                + "<p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; font-family: &quot;맑은 고딕&quot;;'>한국가스안전공사</p>\n"
                + "</td>\n"
                + "<td class='' style='border-width: 1px; border-style: solid; border-color: rgb(0, 0, 0); width: 131px; height: 20px;'>\n"
                + "<p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><br></p>\n"
                + "</td>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 90px; height: 20px;'>\n"
                + "<p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><span style='font-size:10.0pt;line-height:107%;font-family:&quot;맑은 고딕&quot;;'>자동절체기</span></p>\n"
                + "</td>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 88px; height: 20px;'>\n"
                + "<p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><br></p>\n"
                + "</td>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 124px; height: 20px;'>\n"
                + "<p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><br></p>\n"
                + "</td>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 98px; height: 20px;'>\n"
                + "<p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><span style='font-size:10.0pt;line-height:107%;font-family:&quot;맑은 고딕&quot;;'>부속설비</span></p>\n"
                + "</td>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 100px; height: 20px;'>\n"
                + "<p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><br></p>\n"
                + "</td>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 128px; height: 20px;'>\n"
                + "<p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><br></p>\n"
                + "</td>\n"
                + "</tr>\n"
                + "<tr>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 118px; height: 20px;' colspan='2'>\n"
                + "<p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><span style='font-size:10.0pt;line-height:107%;font-family:&quot;맑은 고딕&quot;;'>가스공급자단체</span></p>\n"
                + "</td>\n"
                + "<td class='' style='border-width: 1px; border-style: solid; border-color: rgb(0, 0, 0); width: 131px; height: 20px;'>\n"
                + "<p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><br></p>\n"
                + "</td>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 628px; height: 20px;' colspan='6'>\n"
                + "<p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; font-family: &quot;맑은 고딕&quot;;'>&nbsp;※ 계약체결\n"
                + "시 공급설비가 고객의 소유인 경우 비고란에 '소비자 소유'로\n"
                + "표시합니다.</p>\n"
                + "</td>\n"
                + "</tr>\n"
                + "<tr>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 249px; height: 21px;' colspan='3'>\n"
                + "<p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><span style='font-size:10.0pt;line-height:107%;font-family:&quot;맑은 고딕&quot;;'>판매방법&nbsp; &nbsp;</span><span style='font-family: &quot;맑은 고딕&quot;; font-size: 10pt; text-align: justify;'>[&nbsp;&nbsp; ]</span><span style='font-family: &quot;맑은 고딕&quot;; font-size: 10pt; text-align: justify;'>체적판매</span><span style='font-family: &quot;맑은 고딕&quot;; font-size: 10pt; text-align: justify;'>, [&nbsp;&nbsp; ]</span><span style='font-family: &quot;맑은 고딕&quot;; font-size: 10pt; text-align: justify;'>중량판매</span></p>\n"
                + "</td>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 90px; height: 21px;'>\n"
                + "<p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; font-family: &quot;맑은 고딕&quot;;'>거래현황</p>\n"
                + "</td>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 538px; height: 21px;' colspan='5'>\n"
                + "<p style='margin: 0cm 0cm 8pt; text-align: center; line-height: 107%; font-size: 10pt; font-family: &quot;맑은 고딕&quot;;'>[&nbsp; &nbsp;] 신규, [&nbsp;&nbsp; ] 재계약&nbsp; &nbsp; (종전 가스공급자 상호:&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;)</p>\n"
                + "</td>\n"
                + "</tr>\n"
                + "</tbody>\n"
                + "</table>\n"
                + "<p style='margin-top:0cm;margin-right:0cm;margin-bottom:8.0pt;margin-left:0cm;text-align:justify;text-justify:inter-ideograph;line-height:107%;text-autospace:none;word-break:break-hangul;font-size:10.0pt;font-family:&quot;맑은 고딕&quot;;'><span style='font-size: 9pt; font-family: &quot;맑은 고딕&quot;;'></span>&nbsp;</p>\n"
                + "<table border='1' cellspacing='0' cellpadding='0' style='word-break: normal; font-size: 10pt; width: 886px; border: 1px none rgb(0, 0, 0); border-collapse: collapse; height: 168.594px;'>\n"
                + "<tbody>\n"
                + "<tr>\n"
                + "<td colspan='4' style='border: 1px solid rgb(0, 0, 0); width: 426px; height: 20px;'>\n"
                + "<p style='line-height: 1; font-size: 10pt; text-align: center; font-family: 굴림체; margin-top: 0px; margin-bottom: 0px;'><span style='font-size: 10pt; line-height: 1; font-family: &quot;맑은 고딕&quot;;'>가스공급자</span></p>\n"
                + "</td>\n"
                + "<td colspan='4' style='border: 1px solid rgb(0, 0, 0); width: 458px; height: 20px;'>\n"
                + "<p style='line-height: 1; margin: 0cm 0cm 8pt; text-align: center; font-size: 10pt; font-family: &quot;맑은 고딕&quot;;'>고&nbsp; 객</p>\n"
                + "</td>\n"
                + "</tr>\n"
                + "<tr>\n"
                + "<td colspan='4' style='border: 1px solid rgb(0, 0, 0); width: 426px; height: 142px;'>\n"
                + "<p style='line-height: 14.2667px; margin: 0cm 0cm 8pt; text-align: justify; font-size: 10pt; font-family: &quot;맑은 고딕&quot;;'>&nbsp;사업자등록번호:</p><p style='line-height: 14.2667px; margin: 0cm 0cm 8pt; text-align: justify; font-size: 10pt; font-family: &quot;맑은 고딕&quot;;'>&nbsp;상호:&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp;</p><p style='line-height: 14.2667px; margin: 0cm 0cm 8pt; text-align: justify; font-size: 10pt; font-family: &quot;맑은 고딕&quot;;'>&nbsp;전화번호:</p><p style='line-height: 14.2667px; margin: 0cm 0cm 8pt; text-align: justify; font-size: 10pt; font-family: &quot;맑은 고딕&quot;;'>&nbsp;긴급 시 연락처:</p><p style='line-height: 14.2667px; margin: 0cm 0cm 8pt; text-align: justify; font-size: 10pt; font-family: &quot;맑은 고딕&quot;;'>&nbsp;대표자:&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; (서명 또는 인)</p>\n"
                + "</td>\n"
                + "<td colspan='4' style='border: 1px solid rgb(0, 0, 0); width: 458px; height: 142px;'>\n"
                + "<p style='line-height: 14.2667px; margin: 0cm 0cm 8pt; text-align: justify; font-size: 10pt; font-family: &quot;맑은 고딕&quot;;'>&nbsp;상호:<span style='font-size: 10pt; font-family: &quot;맑은 고딕&quot;;'>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;</span></p><p style='line-height: 14.2667px; margin: 0cm 0cm 8pt; text-align: justify; font-size: 10pt; font-family: &quot;맑은 고딕&quot;;'>&nbsp;성명:<span style='font-size: 10pt; font-family: 굴림체;'>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp;전화번호:</span></p><p style='line-height: 14.2667px; margin: 0cm 0cm 8pt; text-align: justify; font-size: 10pt; font-family: &quot;맑은 고딕&quot;;'>&nbsp;주소:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</p><p style='line-height: 14.2667px; margin: 0cm 0cm 8pt; text-align: justify; font-size: 10pt; font-family: &quot;맑은 고딕&quot;;'><span style='font-size: 10pt; font-family: &quot;맑은 고딕&quot;;'>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;</span><span style='font-size: 10pt; font-family: &quot;맑은 고딕&quot;;'>&nbsp; &nbsp;</span><span style='font-size: 10pt; font-family: &quot;맑은 고딕&quot;;'>&nbsp; &nbsp; &nbsp; &nbsp;</span><span style='font-size: 10pt; font-family: &quot;맑은 고딕&quot;;'>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; 년&nbsp; &nbsp; </span><span style='font-size: 10pt; font-family: &quot;맑은 고딕&quot;;'>&nbsp;</span><span style='font-size: 10pt; font-family: &quot;맑은 고딕&quot;;'>&nbsp;&nbsp; 월&nbsp;&nbsp; &nbsp; &nbsp;</span><span style='font-size: 10pt; font-family: &quot;맑은 고딕&quot;;'>&nbsp;</span><span style='font-size: 10pt; font-family: &quot;맑은 고딕&quot;;'> 일</span></p><p style='line-height: 14.2667px; margin: 0cm 0cm 8pt; text-align: justify; font-size: 10pt; font-family: &quot;맑은 고딕&quot;;'>&nbsp;고객서명:&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; (서명 또는 인)</p>\n"
                + "</td>\n"
                + "</tr>\n"
                + "</tbody>\n"
                + "</table>\n"
                + "<p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'><span style='font-family: &quot;맑은 고딕&quot;; text-align: justify; font-size: 10pt;'>※ 고객과 관련된 정보는 다른 목적으로 사용하거나 누출할 수 없습니다.</span></p>\n";

        return htmlContent;

    }


    public  String AnSafe_file(String filename ) throws IOException {

        Path AnContfile =  pdfFolder.resolve(filename).normalize();
        Resource resource = new UrlResource(AnContfile.toUri());

        String filePath = AnContfile + ".html";

        // HTML 콘텐츠 생성
        String htmlContent = AnSafefile();

        // HTML 파일 생성 및 작성
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(new File(filePath)))) {
            writer.write(htmlContent);
            System.out.println("HTML 파일이 생성되었습니다: " + filePath);

        } catch (IOException e) {
            e.printStackTrace();
        }
        return  filePath ;
    }

    public String AnSafefile(){

        String htmlContent = "<div style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'>[별지&nbsp;3의3]&nbsp;<span style='font-size: 10pt; font-family: 굴림체;'>[액법&nbsp;시행규칙&nbsp;별지&nbsp;제27호&nbsp;서식]</span></div>\n"
                + "<div style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'><b style='font-size: 16pt;'><span style='font-size: 9pt; font-family: 굴림체;'></span></b></div>\n"
                + "<div style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'><b style='font-size: 16pt;'><span style='font-size: 20pt; font-family: 굴림체;'>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; 소비설비 안전점검표</span>&nbsp; &nbsp;&nbsp;</b></div>\n"
                + "<div style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'><p style='text-align: center; font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'><span style='font-size: 16pt;'><b><br></b></span></p></div>\n"
                + "<div style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'><b>점검연월일 :&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;년&nbsp; &nbsp; &nbsp;월&nbsp; &nbsp; &nbsp;일</b></div>\n"
                + "<div style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'><br></div>\n"
                + "<div style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'><b>1.시설현황&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp;&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp;완성검사일 :&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp;&nbsp; &nbsp; &nbsp;정기검사일 :&nbsp;</b></div>\n"
                + "<table border='1' cellspacing='0' cellpadding='0' style='word-break: normal; width: 822px; font-size: 10pt; border: 1px none rgb(0, 0, 0); border-collapse: collapse; height: 221.641px;'>\n"
                + "<tbody>\n"
                + "	<tr>\n"
                + "		<td style='border: 1px solid rgb(0, 0, 0); width: 10px; height: 26px; background-color: rgb(247, 247, 247);' colspan='2'>\n"
                + "			<p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'>배관</p>\n"
                + "		</td>\n"
			    + "     <td style='border: 1px solid rgb(0, 0, 0); width: 83px; height: 26px; background-color: rgb(247, 247, 247);'>\n"
                + "			<p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'>강관</p>\n"
			    + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 98px; height: 26px;'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><br></p>\n"
                + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 85px; height: 26px; background-color: rgb(247, 247, 247);'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'>동관</p>\n"
                + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 93px; height: 26px;'>\n"
                + "        <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><br></p>\n"
                + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 88px; height: 26px; background-color: rgb(247, 247, 247);'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'>호스</p>\n"
                + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 96px; height: 26px;'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><br></p>\n"
                + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 85px; height: 26px; background-color: rgb(247, 247, 247);'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><br></p>\n"
                + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 87px; height: 26px;'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><br></p>\n"
                + "     </td>\n"
                + " </tr>\n"
                + " <tr>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 10px; height: 26px; background-color: rgb(247, 247, 247);' colspan='2'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'>중간밸브</p>\n"
                + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 83px; height: 26px; background-color: rgb(247, 247, 247);'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'>볼밸브</p>\n"
                + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 98px; height: 26px;'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><br></p>\n"
                + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 85px; height: 26px; background-color: rgb(247, 247, 247);'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'>퓨즈콕</p>\n"
                + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 93px; height: 26px;'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><br></p>\n"
                + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 88px; height: 26px; background-color: rgb(247, 247, 247);'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'>호스콕</p>\n"
                + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 96px; height: 26px;'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><br></p>\n"
                + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 85px; height: 26px; background-color: rgb(247, 247, 247);'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'><br></p>\n"
                + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 87px; height: 26px;'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'><br></p>\n"
                + "     </td>\n"
                + " </tr>\n"
                + " <tr>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 10px; background-color: rgb(247, 247, 247); height: 42px;' rowspan='2' colspan='2'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'>그 밖의 사항</p>\n"
                + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 83px; height: 26px; background-color: rgb(247, 247, 247);'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><br></p>\n"
                + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 98px; height: 26px;'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><br></p>\n"
                + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 85px; height: 26px; background-color: rgb(247, 247, 247);'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><br></p>\n"
                + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 93px; height: 26px;'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><br></p>\n"
                + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 88px; height: 26px; background-color: rgb(247, 247, 247);'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><br></p>\n"
                + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 96px; height: 26px;'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><br></p>\n"
                + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 85px; height: 26px; background-color: rgb(247, 247, 247);'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><br></p>\n"
                + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 87px; height: 26px;'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><br></p>\n"
                + "     </td>\n"
                + " </tr>\n"
                + " <tr>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 12px; height: 26px;' colspan='8'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><br></p>\n"
                + "     </td>\n"
                + " </tr>\n"
                + " <tr>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 36px; background-color: rgb(247, 247, 247); height: 129px;' rowspan='5'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'>연</p><p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'>소</p><p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'>기</p>\n"
                + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 65px; height: 26px; background-color: rgb(247, 247, 247);'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'>레인지</p>\n"
                + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 83px; height: 26px; background-color: rgb(247, 247, 247);'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'>2구레인지</p>\n"
                + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 98px; height: 26px;'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><br></p>\n"
                + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 85px; height: 26px; background-color: rgb(247, 247, 247);'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'>3구레인지</p>\n"
                + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 93px; height: 26px;'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><br></p>\n"
                + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 88px; height: 26px; background-color: rgb(247, 247, 247);'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'>오븐레인지</p>\n"
                + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 96px; height: 26px;'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><br></p>\n"
                + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 85px; height: 26px; background-color: rgb(247, 247, 247);'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><br></p>\n"
                + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 87px; height: 26px;'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><br></p>\n"
                + "     </td>\n"
                + " </tr>\n"
                + " <tr>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 65px; height: 26px; background-color: rgb(247, 247, 247);'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'>보일러</p>\n"
                + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 83px; height: 26px; background-color: rgb(247, 247, 247);'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'>형식</p>\n"
                + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 98px; height: 26px;'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><br></p>\n"
                + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 85px; height: 26px; background-color: rgb(247, 247, 247);'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'>위치</p>\n"
                + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 93px; height: 26px;'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><br></p>\n"
                + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 88px; height: 26px; background-color: rgb(247, 247, 247);'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'>가스소비량</p>\n"
                + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 96px; height: 26px;'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><br></p>\n"
                + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 85px; height: 26px; background-color: rgb(247, 247, 247);'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'>시공자</p>\n"
                + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 87px; height: 26px;'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><br></p>\n"
                + "     </td>\n"
                + " </tr>\n"
                + " <tr>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 65px; height: 26px; background-color: rgb(247, 247, 247);'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'>온수기</p>\n"
                + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 83px; height: 26px; background-color: rgb(247, 247, 247);'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'>형식</p>\n"
                + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 98px; height: 26px;'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><br></p>\n"
                + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 85px; height: 26px; background-color: rgb(247, 247, 247);'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'>위치</p>\n"
                + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 93px; height: 26px;'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><br></p>\n"
                + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 88px; height: 26px; background-color: rgb(247, 247, 247);'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'>가스소비량</p>\n"
                + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 96px; height: 26px;'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><br></p>\n"
                + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 85px; height: 26px; background-color: rgb(247, 247, 247);'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'>시공자</p>\n"
                + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 87px; height: 26px;'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><br></p>\n"
                + "     </td>\n"
                + " </tr>\n"
                + " <tr>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 65px; background-color: rgb(247, 247, 247); height: 54px;' rowspan='2'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'>그 밖의</p><p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'>사항</p>\n"
                + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 83px; height: 26px; background-color: rgb(247, 247, 247);'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><br></p>\n"
                + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 98px; height: 26px;'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><br></p>\n"
                + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 85px; height: 26px; background-color: rgb(247, 247, 247);'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><br></p>\n"
                + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 93px; height: 26px;'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><br></p>\n"
                + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 88px; height: 26px; background-color: rgb(247, 247, 247);'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><br></p>\n"
                + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 96px; height: 26px;'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><br></p>\n"
                + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 85px; height: 26px; background-color: rgb(247, 247, 247);'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><br></p>\n"
                + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 87px; height: 26px;'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><br></p>\n"
                + "     </td>\n"
                + " </tr>\n"
                + " <tr>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 12px; height: 26px;' colspan='8'>\n"
                + "         <p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px; text-align: center;'><br></p>\n"
                + "     </td>\n"
                + " </tr>\n"
                + "</tbody>\n"
                + "</table>\n"

                + "<p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'><b style='font-size: 10pt;'>2.점검결과</b></p>\n"
                + "<table border='1' cellspacing='0' cellpadding='0' style='word-break: normal; width: 825px; font-size: 10pt; border: 1px none rgb(0, 0, 0); border-collapse: collapse; height: 455.117px;'>\n"
                + " <tbody>\n"
                + " <tr>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 136px; height: 24px; background-color: rgb(247, 247, 247);' colspan='2'>\n"
                + "         <p style='text-align: center; font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'>구분</p>\n"
                + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 606px; height: 24px; background-color: rgb(247, 247, 247);'>\n"
                + "         <p style='text-align: center; font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'>점검내용</p>\n"
                + "     </td>\n"
                + "     <td style='border: 1px solid rgb(0, 0, 0); width: 78px; height: 24px; background-color: rgb(247, 247, 247);'>\n"
                + "         <p style='text-align: center; font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'>판정</p>\n"
                + "     </td>\n"
                + " </tr>\n"
                + " <tr>\n"
                + "     <td class='' style='border-width: 1px; border-style: solid; border-color: rgb(0, 0, 0); width: 136px; height: 40px;' colspan='2'>\n"
                + "         <p style='text-align: center; font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'>가스누출검사</p>\n"
                + "     </td>\n"
                + "     <td class='' style='border-width: 1px; border-style: solid; border-color: rgb(0, 0, 0); width: 606px; height: 40px;'>\n"
                + "         <p style='margin-left: 0px; font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'>&nbsp;가.&nbsp;가스계량기&nbsp;출구(중량판매의&nbsp;경우&nbsp;용기&nbsp;출구)에서&nbsp;배관,&nbsp;호스&nbsp;및&nbsp;연소기에&nbsp;</p><p style='margin-left: 0px; font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'>&nbsp; &nbsp; &nbsp;이르는&nbsp;각&nbsp;접속부의&nbsp;가스누출&nbsp;여부와&nbsp;막음조치&nbsp;여부</p>\n"
                + "     </td>\n"
                + "     <td class='' style='border-width: 1px; border-style: solid; border-color: rgb(0, 0, 0); width: 78px; height: 40px;'>\n"
                + "         <p style='text-align: center; font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'>적 ㆍ 부</p>\n"
                + "     </td>\n"
                + " </tr>\n"
                + "<tr>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 53px; height: 211.81px;' rowspan='7'>\n"
                + "<p style='text-align: center; font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'>가스</p><p style='text-align: center; font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'>용품의</p><p style='text-align: center; font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'>상태</p><p style='text-align: center; font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'>점검</p>\n"
                + "</td>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 83px; height: 30px;'>\n"
                + "<p style='text-align: center; font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'>검사품</p>\n"
                + "</td>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 606px; height: 30px;'>\n"
                + "<p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'>&nbsp;나.&nbsp;가스용품의&nbsp;한국가스안전공사&nbsp;합격&nbsp;표시&nbsp;또는&nbsp;한국산업표준(KS)&nbsp;검사표시&nbsp;유무</p>\n"
                + "</td>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 78px; height: 30px;'>\n"
                + "<p style='text-align: center; font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'>적&nbsp;ㆍ&nbsp;부</p>\n"
                + "</td>\n"
                + "</tr>\n"
                + "<tr>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 83px; height: 29px;'>\n"
                + "<p style='text-align: center; font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'>중간밸브</p>\n"
                + "</td>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 606px; height: 29px;'>\n"
                + "<p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'>&nbsp;다.&nbsp;연소기마다&nbsp;퓨즈콕ㆍ상자콕&nbsp;또는&nbsp;이와&nbsp;같은&nbsp;수준&nbsp;이상의&nbsp;안전장치&nbsp;설치&nbsp;여부<br></p>\n"
                + "</td>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 78px; height: 29px;'>\n"
                + "<p style='text-align: center; font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'>적&nbsp;ㆍ&nbsp;부</p>\n"
                + "</td>\n"
                + "</tr>\n"
                + "<tr>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 83px; height: 26px;'>\n"
                + "<p style='text-align: center; font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'>호스</p>\n"
                + "</td>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 606px; height: 26px;'>\n"
                + "<p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'>&nbsp;라.&nbsp;'T'형으로의&nbsp;연결금지&nbsp;준수&nbsp;여부&nbsp;및&nbsp;호스밴드&nbsp;접속&nbsp;여부</p>\n"
                + "</td>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 78px; height: 26px;'>\n"
                + "<p style='text-align: center; font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'>적&nbsp;ㆍ&nbsp;부</p>\n"
                + "</td>\n"
                + "</tr>\n"
                + "<tr>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 83px; height: 126px;' rowspan='4'>\n"
                + "<p style='text-align: center; font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'>연소기</p>\n"
                + "</td>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 606px; height: 30px;'>\n"
                + "<p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'>&nbsp;마.&nbsp;목욕탕이나&nbsp;화장실에의&nbsp;보일러ㆍ온수기&nbsp;설치금지&nbsp;규정&nbsp;준수&nbsp;여부<br></p>\n"
                + "</td>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 78px; height: 30px;'>\n"
                + "<p style='text-align: center; font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'>적&nbsp;ㆍ&nbsp;부</p>\n"
                + "</td>\n"
                + "</tr>\n"
                + "<tr>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 606px; height: 40px;'>\n"
                + "<p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'>&nbsp;바.&nbsp;전용보일러실에의&nbsp;<span style='font-family: 굴림체; font-size: 10pt;'>보일러(밀폐식&nbsp;보일러&nbsp;또는&nbsp;옥외에&nbsp;설치한&nbsp;보일러는&nbsp;제외)를&nbsp;</span></p><p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'><span style='font-family: 굴림체; font-size: 10pt;'>&nbsp; &nbsp; &nbsp;설치하였는지&nbsp;여부</span><br></p>\n"
                + "</td>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 78px; height: 40px;'>\n"
                + "<p style='text-align: center; font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'>적&nbsp;ㆍ&nbsp;부</p>\n"
                + "</td>\n"
                + "</tr>\n"
                + "<tr>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 606px; height: 27px;'>\n"
                + "<p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'>&nbsp;사.&nbsp;<span style='font-family: 굴림체; font-size: 10pt;'>배기통이&nbsp;한국가스안전공사&nbsp;또는&nbsp;공인시험기관의&nbsp;성능인증을&nbsp;받은&nbsp;제품인지&nbsp;여부</span><br></p>\n"
                + "</td>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 78px; height: 27px;'>\n"
                + "<p style='text-align: center; font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'>적&nbsp;ㆍ&nbsp;부</p>\n"
                + "</td>\n"
                + "</tr>\n"
                + "<tr>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 606px; height: 29px;'>\n"
                + "<p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'>&nbsp;아.&nbsp;<span style='font-family: 굴림체; font-size: 10pt;'>가스보일러&nbsp;및&nbsp;가스온수기와&nbsp;배기통,&nbsp;배기통과&nbsp;배기통&nbsp;이탈&nbsp;여부</span><br></p>\n"
                + "</td>\n"
                + "<td style='border: 1px solid rgb(0, 0, 0); width: 78px; height: 29px;'>\n"
                + "<p style='text-align: center; font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'>적&nbsp;ㆍ&nbsp;부</p>\n"
                + "</td>\n"
                + "</tr>\n"
                + "<tr>\n"
                + "<td class='' style='border-width: 1px; border-style: solid; border-color: rgb(0, 0, 0); width: 136px; height: 136px;' colspan='2' rowspan='4'>\n"
                + "<p style='text-align: center; font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'>그 밖의 사항</p>\n"
                + "</td>\n"
                + "<td class='' style='border-width: 1px; border-style: solid; border-color: rgb(0, 0, 0); width: 606px; height: 32px;'>\n"
                + "<p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'>&nbsp;자.&nbsp;용기의&nbsp;옥내설치(보관)&nbsp;여부<br></p>\n"
                + "</td>\n"
                + "<td class='' style='border-width: 1px; border-style: solid; border-color: rgb(0, 0, 0); width: 78px; height: 32px;'>\n"
                + "<p style='text-align: center; font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'>적&nbsp;ㆍ&nbsp;부</p>\n"
                + "</td>\n"
                + "</tr>\n"
                + "<tr>\n"
                + "<td class='' style='border-width: 1px; border-style: solid; border-color: rgb(0, 0, 0); width: 606px; height: 40px;'>\n"
                + "<p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'>&nbsp;차.&nbsp;압력조정기에서&nbsp;중간밸브까지의&nbsp;배관이&nbsp;별표&nbsp;20&nbsp;제1호가목4)라)에&nbsp;적합하게&nbsp;강관ㆍ동관&nbsp;또는&nbsp;금속플렉시블호스&nbsp;등으로&nbsp;설치되어&nbsp;있는지&nbsp;여부<br></p>\n"
                + "</td>\n"
                + "<td class='' style='border-width: 1px; border-style: solid; border-color: rgb(0, 0, 0); width: 78px; height: 40px;'>\n"
                + "<p style='text-align: center; font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'>적&nbsp;ㆍ&nbsp;부</p>\n"
                + "</td>\n"
                + "</tr>\n"
                + "<tr>\n"
                + "<td class='' style='border-width: 1px; border-style: solid; border-color: rgb(0, 0, 0); width: 606px; height: 32px;'>\n"
                + "<p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'>&nbsp;카.&nbsp;일산화탄소&nbsp;경보기&nbsp;설치&nbsp;여부<br></p>\n"
                + "</td>\n"
                + "<td class='' style='border-width: 1px; border-style: solid; border-color: rgb(0, 0, 0); width: 78px; height: 32px;'>\n"
                + "<p style='text-align: center; font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'>적&nbsp;ㆍ&nbsp;부</p>\n"
                + "</td>\n"
                + "</tr>\n"
                + "<tr>\n"
                + "<td class='' style='border-width: 1px; border-style: solid; border-color: rgb(0, 0, 0); width: 606px; height: 32px;'>\n"
                + "<p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'>&nbsp;타.&nbsp;그&nbsp;밖에&nbsp;가스사고를&nbsp;유발할&nbsp;우려가&nbsp;없는지&nbsp;여부<br></p>\n"
                + "</td>\n"
                + "<td class='' style='border-width: 1px; border-style: solid; border-color: rgb(0, 0, 0); width: 78px; height: 32px;'>\n"
                + "<p style='text-align: center; font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'>적&nbsp;ㆍ&nbsp;부</p>\n"
                + "</td>\n"
                + "</tr>\n"
                + "<tr>\n"
                + "<td class='' style='border-width: 1px; border-style: solid; border-color: rgb(0, 0, 0); width: 136px; height: 31px;' colspan='2'>\n"
                + "<p style='text-align: center; font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'>가스용품의&nbsp;</p><p style='text-align: center; font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'>권장사용기간<br></p>\n"
                + "</td>\n"
                + "<td class='' style='border-width: 1px; border-style: solid; border-color: rgb(0, 0, 0); width: 595px; height: 31px;'>\n"
                + "<p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'>&nbsp;파.&nbsp;압력조정기ㆍ고압호스ㆍ저압호스ㆍ퓨즈콕&nbsp;및&nbsp;가스보일러의&nbsp;권장사용기간&nbsp;경과&nbsp;여부<br></p>\n"
                + "</td>\n"
                + "<td class='' style='border-width: 1px; border-style: solid; border-color: rgb(0, 0, 0); width: 89px; height: 31px;'>\n"
                + "<p style='text-align: center; font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'>적&nbsp;ㆍ&nbsp;부</p>\n"
                + "</td>\n"
                + "</tr>\n"
                + "</tbody>\n"
                + "</table>\n"
                + "<p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'><span style='font-size: 9pt; font-family: 굴림체;'>&nbsp;</span></p>\n"
                + "<table border='1' cellspacing='0' cellpadding='0' style='word-break: normal; width: 825px; font-size: 10pt; border: 1px none rgb(0, 0, 0); border-collapse: collapse;'>\n"
                + "<tbody>\n"
                + "<tr>\n"
                + "<td class='' style='border-width: 1px; border-style: solid; border-color: rgb(0, 0, 0); width: 136px; height: 43px;'>\n"
                + "<p style='line-height: 20px; text-align: center; font-size: 10pt; font-family: 굴림체; margin-top: 0px; margin-bottom: 0px;'>개선통지사항</p>\n"
                + "</td>\n"
                + "<td class='' style='border-width: 1px; border-style: solid; border-color: rgb(0, 0, 0); width: 685px; height: 43px;'>\n"
                + "<p style='line-height: 20px; font-size: 10pt; font-family: 굴림체; margin-top: 0px; margin-bottom: 0px;'><br></p><p style='line-height: 20px; font-size: 10pt; font-family: 굴림체; margin-top: 0px; margin-bottom: 0px;'><br></p><p style='line-height: 20px; font-size: 10pt; font-family: 굴림체; margin-top: 0px; margin-bottom: 0px;'><span style='font-size: 9pt; font-family: 굴림체;'>※&nbsp;압력조정기에서&nbsp;중간밸브까지의&nbsp;배관이&nbsp;별표&nbsp;20&nbsp;제1호가목4)라)에&nbsp;적합하게&nbsp;강관ㆍ동관&nbsp;또는&nbsp;금속플렉시블호스로&nbsp;설치되어&nbsp;있지&nbsp;않은&nbsp;주택은&nbsp;2030년&nbsp;12월&nbsp;31일까지&nbsp;해당&nbsp;배관으로&nbsp;교체해야&nbsp;합니다.</span></p>\n"
                + "</td>\n"
                + "</tr>\n"
                + "</tbody>\n"
                + "</table>\n"
                + "<p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'><span style='font-size: 9pt; font-family: 굴림체;'>&nbsp;</span><br></p>\n"
                + "<table border='1' cellspacing='0' cellpadding='0' style='word-break: normal; width: 824px; font-size: 10pt; border: 1px none rgb(0, 0, 0); border-collapse: collapse; height: 55.8333px;'>\n"
                + "<tbody>\n"
                + "<tr>\n"
                + "<td class='' style='border-width: 1px; border-style: solid; border-color: rgb(0, 0, 0); width: 136px; height: 55px;'>\n"
                + "<p style='line-height: 20px; text-align: center; font-size: 10pt; font-family: 굴림체; margin-top: 0px; margin-bottom: 0px;'>가스용품 교체</p><p style='line-height: 20px; text-align: center; font-size: 10pt; font-family: 굴림체; margin-top: 0px; margin-bottom: 0px;'>권장사항</p>\n"
                + "</td>\n"
                + "<td class='' style='border-width: 1px; border-style: solid; border-color: rgb(0, 0, 0); width: 684px; height: 55px;'>\n"
                + "<p style='line-height: 20px; font-size: 10pt; font-family: 굴림체; margin-top: 0px; margin-bottom: 0px;'><br></p>\n"
                + "</td>\n"
                + "</tr>\n"
                + "</tbody>\n"
                + "</table>\n"
                + "<p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'><span style='font-size: 9pt; font-family: 굴림체;'>&nbsp;</span><br></p>\n"
                + "<table border='1' cellspacing='0' cellpadding='0' style='word-break: normal; width: 826px; font-size: 10pt; border: 1px none rgb(0, 0, 0); border-collapse: collapse; height: 120.833px;'>\n"
                + "<tbody>\n"
                + "<tr>\n"
                + "<td class='' style='border-width: 1px; border-style: solid; border-color: rgb(0, 0, 0); width: 53px; height: 120px;'>\n"
                + "<p style='line-height: 20px; text-align: center; font-size: 10pt; font-family: 굴림체; margin-top: 0px; margin-bottom: 0px;'>가스</p><p style='line-height: 20px; text-align: center; font-size: 10pt; font-family: 굴림체; margin-top: 0px; margin-bottom: 0px;'>공급자</p>\n"
                + "</td>\n"
                + "<td class='' style='border-width: 1px; border-style: solid; border-color: rgb(0, 0, 0); width: 333px; height: 120px;'>\n"
                + "<p style='line-height: 2; text-align: left; font-size: 10pt; font-family: 굴림체; margin-top: 0px; margin-bottom: 0px;'><span style='font-size: 10pt; font-family: 굴림체;'>&nbsp;사업자명:</span></p><p style='line-height: 2; text-align: left; font-size: 10pt; font-family: 굴림체; margin-top: 0px; margin-bottom: 0px;'>&nbsp;주소:<br>&nbsp;전화번호:<br>&nbsp;점검자명:&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;(서명&nbsp;또는&nbsp;인)</p>\n"
                + "</td>\n"
                + "<td class='' style='border-width: 1px; border-style: solid; border-color: rgb(0, 0, 0); width: 60px; height: 120px;'>\n"
                + "<p style='line-height: 20px; font-size: 10pt; text-align: center; font-family: 굴림체; margin-top: 0px; margin-bottom: 0px;'>소비자</p>\n"
                + "</td>\n"
                + "<td class='' style='border-width: 1px; border-style: solid; border-color: rgb(0, 0, 0); width: 376px; height: 120px;'>\n"
                + "<p style='line-height: 2; text-align: left; font-size: 10pt; font-family: 굴림체; margin-top: 0px; margin-bottom: 0px;'>&nbsp;상호:<br>&nbsp;주소:<br>&nbsp;전화번호:<br>&nbsp;성명:&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(서명&nbsp;또는&nbsp;인)<br></p>\n"
                + "</td>\n"
                + "</tr>\n"
                + "</tbody>\n"
                + "</table>\n"
                + "<p style='font-family: 굴림체; font-size: 10pt; line-height: 150%; margin-top: 0px; margin-bottom: 0px;'>※&nbsp;개선기한&nbsp;내에&nbsp;시설을&nbsp;개선하지&nbsp;않은&nbsp;상태에서&nbsp;가스사고가&nbsp;발생하는&nbsp;경우에는&nbsp;보험혜택을&nbsp;받을&nbsp;수&nbsp;없습니다.</p>\n";


        return htmlContent;
    }


}
