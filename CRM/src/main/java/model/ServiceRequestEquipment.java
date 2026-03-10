package model;

// ── ServiceRequestEquipment ──────────────────────────────────────
public class ServiceRequestEquipment {

    private int id;
    private int serviceRequestId;
    private int customerEquipmentId;
    private String issueDescription;
    // Joined fields
    private String displayName;
    private String displaySerial;
    private String source;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getServiceRequestId() {
        return serviceRequestId;
    }

    public void setServiceRequestId(int serviceRequestId) {
        this.serviceRequestId = serviceRequestId;
    }

    public int getCustomerEquipmentId() {
        return customerEquipmentId;
    }

    public void setCustomerEquipmentId(int customerEquipmentId) {
        this.customerEquipmentId = customerEquipmentId;
    }

    public String getIssueDescription() {
        return issueDescription;
    }

    public void setIssueDescription(String issueDescription) {
        this.issueDescription = issueDescription;
    }

    public String getDisplayName() {
        return displayName;
    }

    public void setDisplayName(String displayName) {
        this.displayName = displayName;
    }

    public String getDisplaySerial() {
        return displaySerial;
    }

    public void setDisplaySerial(String displaySerial) {
        this.displaySerial = displaySerial;
    }

    public String getSource() {
        return source;
    }

    public void setSource(String source) {
        this.source = source;
    }
}
