package com.example.hellokind

case class DatabaseConfig(host: String, port: Int, username: String, password: String)
case class AppConfig(database: DatabaseConfig)
