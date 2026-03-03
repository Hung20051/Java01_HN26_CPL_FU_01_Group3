package model;

import java.io.Serializable;

public class CartItem implements Serializable {
    private static final long serialVersionUID = 1L;

    private int    typeId;     // part_type_id hoặc equipment_type_id
    private String itemType;   // "PART" hoặc "EQUIPMENT"
    private String name;
    private String categoryName;
    private double unitPrice;
    private int    quantity;
    private int    maxQty;     // số unit available trong kho

    public CartItem() {}
    public CartItem(int typeId, String itemType, String name, String categoryName,
                    double unitPrice, int quantity, int maxQty) {
        this.typeId = typeId; this.itemType = itemType; this.name = name;
        this.categoryName = categoryName; this.unitPrice = unitPrice;
        this.quantity = quantity; this.maxQty = maxQty;
    }

    public double getSubtotal() { return unitPrice * quantity; }

    // key dùng để identify trong giỏ: "PART_1", "EQUIPMENT_3"
    public String getKey() { return itemType + "_" + typeId; }

    public int getTypeId() { return typeId; }
    public void setTypeId(int typeId) { this.typeId = typeId; }
    public String getItemType() { return itemType; }
    public void setItemType(String itemType) { this.itemType = itemType; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }
    public double getUnitPrice() { return unitPrice; }
    public void setUnitPrice(double unitPrice) { this.unitPrice = unitPrice; }
    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }
    public int getMaxQty() { return maxQty; }
    public void setMaxQty(int maxQty) { this.maxQty = maxQty; }
}