package com.example.hellokind

import cats.effect.IO
import org.http4s._
import org.http4s.implicits._
import munit.CatsEffectSuite

class HelloWorldSpec extends CatsEffectSuite {
  private val databaseConfig = DatabaseConfig("host", 1, "username", "password")

  test("HelloWorld returns status code 200") {
    assertIO(retHelloWorld.map(_.status), Status.Ok)
  }

  test("HelloWorld returns hello world message") {
    assertIO(
      retHelloWorld.flatMap(_.as[String]),
      s"{\"message\":\"Hello, world, with data base information $databaseConfig! Don't do this\"}"
    )
  }

  private[this] val retHelloWorld: IO[Response[IO]] = {
    val getHW      = Request[IO](Method.GET, uri"/hello/world")
    val helloWorld = HelloWorld.impl[IO](databaseConfig)
    HellokindRoutes.helloWorldRoutes(helloWorld).orNotFound(getHW)
  }
}
