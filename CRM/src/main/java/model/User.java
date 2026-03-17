package model;

import java.time.LocalDate;
import java.time.Period;
import java.time.format.DateTimeFormatter;

public class User {

    // ── Core fields ──────────────────────────────────────
    private int    id;
    private String fullName;
    private String email;
    private String phone;
    private String username;
    private String password;
    private String authProvider;
    private String providerId;
    private String avatarUrl;
    private int    roleId;
    private String roleName;
    private boolean active;

    // ── Address (for technician dispatch) ────────────────
    private String addressStreet;    // Số nhà, tên đường
    private String addressWard;      // Phường / Xã
    private String addressDistrict;  // Quận / Huyện
    private String addressCity;      // Tỉnh / Thành phố
    private String addressFull;      // Địa chỉ đầy đủ (concat)

    // ── Personal info ────────────────────────────────────
    private String    hometown;      // Quê quán
    private LocalDate dateOfBirth;   // Ngày sinh
    private String    gender;        // MALE / FEMALE / OTHER
    private String    nationalId;    // CCCD / CMND

    // ── Emergency contact ────────────────────────────────
    private String emergencyName;
    private String emergencyPhone;
    private String emergencyRelation;

    // ── Professional info ────────────────────────────────
    private String companyName;
    private String bio;

    // ═══════════════════════════════════════════════════
    //  Helpers
    // ═══════════════════════════════════════════════════

    /** Tự build địa chỉ đầy đủ từ các thành phần (dùng khi chưa có addressFull trong DB) */
    public String buildFullAddress() {
        StringBuilder sb = new StringBuilder();
        if (addressStreet   != null && !addressStreet.isBlank())   sb.append(addressStreet);
        if (addressWard     != null && !addressWard.isBlank())      { if (sb.length()>0) sb.append(", "); sb.append(addressWard); }
        if (addressDistrict != null && !addressDistrict.isBlank())  { if (sb.length()>0) sb.append(", "); sb.append(addressDistrict); }
        if (addressCity     != null && !addressCity.isBlank())      { if (sb.length()>0) sb.append(", "); sb.append(addressCity); }
        return sb.toString();
    }

    /** Tính tuổi từ ngày sinh */
    public int getAge() {
        if (dateOfBirth == null) return 0;
        return Period.between(dateOfBirth, LocalDate.now()).getYears();
    }

    /** Ngày sinh dạng dd/MM/yyyy */
    public String getDateOfBirthFormatted() {
        if (dateOfBirth == null) return "";
        return dateOfBirth.format(DateTimeFormatter.ofPattern("dd/MM/yyyy"));
    }

    /** Ngày sinh dạng yyyy-MM-dd cho input[type=date] */
    public String getDateOfBirthIso() {
        if (dateOfBirth == null) return "";
        return dateOfBirth.toString();
    }

    /** Label tiếng Việt cho giới tính */
    public String getGenderLabel() {
        if (gender == null) return "";
        return switch (gender) {
            case "MALE"   -> "Nam";
            case "FEMALE" -> "Nữ";
            case "OTHER"  -> "Khác";
            default       -> gender;
        };
    }

    // ═══════════════════════════════════════════════════
    //  Getters & Setters — Core
    // ═══════════════════════════════════════════════════

    public int     getId()           { return id; }
    public void    setId(int id)     { this.id = id; }

    public String  getFullName()                { return fullName; }
    public void    setFullName(String fullName) { this.fullName = fullName; }

    public String  getEmail()              { return email; }
    public void    setEmail(String email)  { this.email = email; }

    public String  getPhone()              { return phone; }
    public void    setPhone(String phone)  { this.phone = phone; }

    public String  getUsername()                  { return username; }
    public void    setUsername(String username)    { this.username = username; }

    public String  getPassword()                  { return password; }
    public void    setPassword(String password)   { this.password = password; }

    public String  getAuthProvider()                      { return authProvider; }
    public void    setAuthProvider(String authProvider)   { this.authProvider = authProvider; }

    public String  getProviderId()                    { return providerId; }
    public void    setProviderId(String providerId)   { this.providerId = providerId; }

    public String  getAvatarUrl()                    { return avatarUrl; }
    public void    setAvatarUrl(String avatarUrl)    { this.avatarUrl = avatarUrl; }

    public int     getRoleId()               { return roleId; }
    public void    setRoleId(int roleId)     { this.roleId = roleId; }

    public String  getRoleName()                    { return roleName; }
    public void    setRoleName(String roleName)     { this.roleName = roleName; }

    public boolean isActive()                   { return active; }
    public void    setActive(boolean active)    { this.active = active; }

    // ═══════════════════════════════════════════════════
    //  Getters & Setters — Address
    // ═══════════════════════════════════════════════════

    public String getAddressStreet()                         { return addressStreet; }
    public void   setAddressStreet(String addressStreet)     { this.addressStreet = addressStreet; }

    public String getAddressWard()                           { return addressWard; }
    public void   setAddressWard(String addressWard)         { this.addressWard = addressWard; }

    public String getAddressDistrict()                           { return addressDistrict; }
    public void   setAddressDistrict(String addressDistrict)     { this.addressDistrict = addressDistrict; }

    public String getAddressCity()                       { return addressCity; }
    public void   setAddressCity(String addressCity)     { this.addressCity = addressCity; }

    public String getAddressFull()                           { return addressFull; }
    public void   setAddressFull(String addressFull)         { this.addressFull = addressFull; }

    // ═══════════════════════════════════════════════════
    //  Getters & Setters — Personal Info
    // ═══════════════════════════════════════════════════

    public String    getHometown()                   { return hometown; }
    public void      setHometown(String hometown)    { this.hometown = hometown; }

    public LocalDate getDateOfBirth()                        { return dateOfBirth; }
    public void      setDateOfBirth(LocalDate dateOfBirth)   { this.dateOfBirth = dateOfBirth; }

    public String getGender()                  { return gender; }
    public void   setGender(String gender)     { this.gender = gender; }

    public String getNationalId()                    { return nationalId; }
    public void   setNationalId(String nationalId)   { this.nationalId = nationalId; }

    // ═══════════════════════════════════════════════════
    //  Getters & Setters — Emergency Contact
    // ═══════════════════════════════════════════════════

    public String getEmergencyName()                         { return emergencyName; }
    public void   setEmergencyName(String emergencyName)     { this.emergencyName = emergencyName; }

    public String getEmergencyPhone()                        { return emergencyPhone; }
    public void   setEmergencyPhone(String emergencyPhone)   { this.emergencyPhone = emergencyPhone; }

    public String getEmergencyRelation()                             { return emergencyRelation; }
    public void   setEmergencyRelation(String emergencyRelation)     { this.emergencyRelation = emergencyRelation; }

    // ═══════════════════════════════════════════════════
    //  Getters & Setters — Professional
    // ═══════════════════════════════════════════════════

    public String getCompanyName()                       { return companyName; }
    public void   setCompanyName(String companyName)     { this.companyName = companyName; }

    public String getBio()             { return bio; }
    public void   setBio(String bio)   { this.bio = bio; }
}