package com.nhnacademy.gitaction_practice.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class HomeController {

    @GetMapping("/")
    public String home(Model model) {
        model.addAttribute("word", "hello word!!!!!!!!!!!!!!!!진짜 마지fsdfdasfsdffdsfds막");
        return "index";
    }
}
