name := """play-scala"""
version := "1.0-SNAPSHOT"

lazy val root = (project in file(".")).enablePlugins(PlayScala)

scalaVersion := "2.11.7"
routesGenerator := InjectedRoutesGenerator
