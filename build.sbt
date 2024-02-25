val Http4sVersion          = "1.0.0-M35"
val CirceVersion           = "0.14.3"
val MunitVersion           = "0.7.29"
val LogbackVersion         = "1.2.11"
val MunitCatsEffectVersion = "1.0.7"
val PureconfigVersion      = "0.17.6"

ThisBuild / scapegoatVersion := "1.4.17"
lazy val root = (project in file("."))
  .settings(
    organization := "com.example",
    name         := "hello-kind",
    version      := (git.gitHeadCommit.value map { sha => s"v$sha" }).getOrElse("init"),
    scalaVersion := "2.13.8",
    libraryDependencies ++= Seq(
      "org.http4s"            %% "http4s-ember-server"    % Http4sVersion,
      "org.http4s"            %% "http4s-ember-client"    % Http4sVersion,
      "org.http4s"            %% "http4s-circe"           % Http4sVersion,
      "org.http4s"            %% "http4s-dsl"             % Http4sVersion,
      "io.circe"              %% "circe-generic"          % CirceVersion,
      "org.scalameta"         %% "munit"                  % MunitVersion           % Test,
      "org.typelevel"         %% "munit-cats-effect-3"    % MunitCatsEffectVersion % Test,
      "ch.qos.logback"         % "logback-classic"        % LogbackVersion         % Runtime,
      "org.scalameta"         %% "svm-subs"               % "20.2.0",
      "com.github.pureconfig" %% "pureconfig"             % PureconfigVersion,
      "com.github.pureconfig" %% "pureconfig-cats-effect" % PureconfigVersion
    ),
    addCompilerPlugin("org.typelevel" %% "kind-projector"     % "0.13.2" cross CrossVersion.full),
    addCompilerPlugin("com.olegpy"    %% "better-monadic-for" % "0.3.1"),
    testFrameworks += new TestFramework("munit.Framework")
  )
  .enablePlugins(DockerPlugin, JavaServerAppPackaging, GitVersioning)
