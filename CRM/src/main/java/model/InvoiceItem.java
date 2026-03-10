package model;

import java.math.BigDecimal;

public class InvoiceItem {

    private int id;
    private int invoiceId;
    private String itemName;
    private String itemType;
    private int quantity;
    private BigDecimal unitPrice;
    private BigDecimal totalPrice;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getInvoiceId() {
        return invoiceId;
    }

    public void setInvoiceId(int v) {
        invoiceId = v;
    }

    public String getItemName() {
        return itemName;
    }

    public void setItemName(String v) {
        itemName = v;
    }

    public String getItemType() {
        return itemType;
    }

    public void setItemType(String v) {
        itemType = v;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int v) {
        quantity = v;
    }

    public BigDecimal getUnitPrice() {
        return unitPrice;
    }

    public void setUnitPrice(BigDecimal v) {
        unitPrice = v;
    }

    public BigDecimal getTotalPrice() {
        return totalPrice;
    }

    public void setTotalPrice(BigDecimal v) {
        totalPrice = v;
    }
}
