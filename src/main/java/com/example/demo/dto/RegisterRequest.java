package com.example.demo.dto;

import lombok.Data;

@Data
public class RegisterRequest {
    public String email;
    public String password;
    public String fullName;
    public String phone;
}
