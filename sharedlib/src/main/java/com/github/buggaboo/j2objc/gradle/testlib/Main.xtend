package com.github.buggaboo.j2objc.gradle.testlib

class MyType {
	public def getString() {
		return 'string'
	}

	public static def getMoreString() {
		return 'moar string'
	}
}

class MyClazz {
	public def getString() {
		return new MyType().string
	}

	public static def getMoreString() {
		return MyType.moreString
	}
}