package model;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
public class Invoice {
    private int id; private String invoiceCode; private int customerId;
    private String customerName; private Integer serviceRequestId; private String requestCode;
    private String invoiceType; private BigDecimal subtotal; private BigDecimal taxPercent;
    private BigDecimal taxAmount; private BigDecimal totalAmount; private String status;
    private LocalDate dueDate; private String notes; private int createdBy;
    private String createdByName; private LocalDateTime createdAt; private List<InvoiceItem> items;
    public String getStatusLabel() {
        if("UNPAID".equals(status)) return "Chưa thanh toán";
        if("PAID".equals(status))   return "Đã thanh toán";
        if("CANCELLED".equals(status)) return "Đã hủy";
        return status;
    }
    public String getInvoiceTypeLabel(){return "REPAIR".equals(invoiceType)?"Sửa chữa":"Mua hàng";}
    public int getId(){return id;} public void setId(int id){this.id=id;}
    public String getInvoiceCode(){return invoiceCode;} public void setInvoiceCode(String v){invoiceCode=v;}
    public int getCustomerId(){return customerId;} public void setCustomerId(int v){customerId=v;}
    public String getCustomerName(){return customerName;} public void setCustomerName(String v){customerName=v;}
    public Integer getServiceRequestId(){return serviceRequestId;} public void setServiceRequestId(Integer v){serviceRequestId=v;}
    public String getRequestCode(){return requestCode;} public void setRequestCode(String v){requestCode=v;}
    public String getInvoiceType(){return invoiceType;} public void setInvoiceType(String v){invoiceType=v;}
    public BigDecimal getSubtotal(){return subtotal;} public void setSubtotal(BigDecimal v){subtotal=v;}
    public BigDecimal getTaxPercent(){return taxPercent;} public void setTaxPercent(BigDecimal v){taxPercent=v;}
    public BigDecimal getTaxAmount(){return taxAmount;} public void setTaxAmount(BigDecimal v){taxAmount=v;}
    public BigDecimal getTotalAmount(){return totalAmount;} public void setTotalAmount(BigDecimal v){totalAmount=v;}
    public String getStatus(){return status;} public void setStatus(String v){status=v;}
    public LocalDate getDueDate(){return dueDate;} public void setDueDate(LocalDate v){dueDate=v;}
    public String getNotes(){return notes;} public void setNotes(String v){notes=v;}
    public int getCreatedBy(){return createdBy;} public void setCreatedBy(int v){createdBy=v;}
    public String getCreatedByName(){return createdByName;} public void setCreatedByName(String v){createdByName=v;}
    public LocalDateTime getCreatedAt(){return createdAt;} public void setCreatedAt(LocalDateTime v){createdAt=v;}
    public List<InvoiceItem> getItems(){return items;} public void setItems(List<InvoiceItem> v){items=v;}
}