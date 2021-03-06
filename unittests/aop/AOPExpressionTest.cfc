﻿<!---
   Copyright 2011 Mark Mandel
   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at
       http://www.apache.org/licenses/LICENSE-2.0
   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
 --->

<cfcomponent hint="tests for generating aop proxies" extends="unittests.AbstractTestCase" output="false">

<!------------------------------------------- PUBLIC ------------------------------------------->

<cffunction name="setup" hint="setup, create a proxy factory" access="public" returntype="void" output="false">
	<cfscript>
		proxyFactory = createObject("component", "coldspring.aop.framework.ProxyFactory").init();
		hello = createObject("component", "unittests.aop.com.Hello").init();
		goodbye = createObject("component", "unittests.aop.com.Goodbye").init();
		interceptor = createObject("component", "unittests.aop.com.ReverseMethodInterceptor").init();
		pointcut = createObject("component", "coldspring.aop.expression.ExpressionPointcut").init();
    </cfscript>
</cffunction>

<cffunction name="testSimpleAnnotation" hint="test simple reverse advice" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};

		pointcut.setExpression("@annotation(dostuff='true')");

		local.advisor = createObject("component", "coldspring.aop.PointcutAdvisor").init(pointcut, interceptor);

		proxyFactory.addAdvisor(local.advisor);

		local.proxy = proxyFactory.getProxy(hello);

		local.value = local.proxy.sayHello();

		assertEquals("hello", local.value);

		assertEquals(reverse("Goodbye"), local.proxy.sayGoodbye());

		local.string = "Gobble, Gobble";

		assertEquals(local.string, local.proxy.sayHello(local.string));
	</cfscript>
</cffunction>

<cffunction name="testNotSimpleAnnotation" hint="test simple reverse advice, negated" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};

		pointcut.setExpression("!@annotation(dostuff='true')");

		local.advisor = createObject("component", "coldspring.aop.PointcutAdvisor").init(pointcut, interceptor);

		proxyFactory.addAdvisor(local.advisor);

		local.proxy = proxyFactory.getProxy(hello);

		local.value = local.proxy.sayHello();

		assertEquals(reverse("hello"), local.value);

		local.string = "Gobble, Gobble";

		assertEquals(reverse(local.string), local.proxy.sayHello(local.string));

		assertEquals("Goodbye", local.proxy.sayGoodbye());
	</cfscript>
</cffunction>

<cffunction name="testAndExpression" hint="test a simple AND expression" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};

		pointcut.setExpression("@annotation(dostuff='true') AND @target(dothings='true')");

		local.advisor = createObject("component", "coldspring.aop.PointcutAdvisor").init(pointcut, interceptor);

		proxyFactory.addAdvisor(local.advisor);

		local.proxy = proxyFactory.getProxy(hello);

		local.value = local.proxy.sayHello();

		assertEquals("hello", local.value);

		assertEquals("Goodbye", local.proxy.sayGoodbye());

		local.string = "Gobble, Gobble";

		assertEquals(local.string, local.proxy.sayHello(local.string));
	</cfscript>
</cffunction>

<cffunction name="testTripleAndExpression" hint="test a 3 deep and and then ! expression" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};

		pointcut.setExpression("@annotation(dostuff='true') AND @target(dothings='true') AND !@target(notdothings)");

		local.advisor = createObject("component", "coldspring.aop.PointcutAdvisor").init(pointcut, interceptor);

		proxyFactory.addAdvisor(local.advisor);

		local.proxy = proxyFactory.getProxy(hello);

		local.value = local.proxy.sayHello();

		assertEquals("hello", local.value);

		assertEquals("Goodbye", local.proxy.sayGoodbye());

		local.string = "Gobble, Gobble";

		assertEquals(local.string, local.proxy.sayHello(local.string));
	</cfscript>
</cffunction>

<cffunction name="testORExpression" hint="test a simple AND expression" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};

		pointcut.setExpression("@annotation(dostuff='true') OR @annotation(dothings='true')");

		local.advisor = createObject("component", "coldspring.aop.PointcutAdvisor").init(pointcut, interceptor);

		proxyFactory.addAdvisor(local.advisor);

		local.proxy = proxyFactory.getProxy(hello);

		local.value = local.proxy.sayHello();

		assertEquals(reverse("hello"), local.value);

		assertEquals(reverse("Goodbye"), local.proxy.sayGoodbye());

		local.string = "Gobble, Gobble";

		assertEquals(reverse(local.string), local.proxy.sayHello(local.string));
	</cfscript>
</cffunction>

<cffunction name="testDoubleNotANDExpression" hint="test a double not AND expression" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};

		pointcut.setExpression("!@annotation(dostuff='true') AND !@annotation(dothings='true')");

		local.advisor = createObject("component", "coldspring.aop.PointcutAdvisor").init(pointcut, interceptor);

		proxyFactory.addAdvisor(local.advisor);

		local.proxy = proxyFactory.getProxy(hello);

		local.value = local.proxy.sayHello();

		assertEquals("hello", local.value);

		assertEquals("Goodbye", local.proxy.sayGoodbye());

		local.string = "Gobble, Gobble";

		assertEquals(local.string, local.proxy.sayHello(local.string));

		local.proxy = proxyFactory.getProxy(goodbye);

		local.value = local.proxy.sayHello();

		assertEquals(reverse("hello"), local.value);

		assertEquals(reverse("Goodbye"), local.proxy.sayGoodbye());

		local.string = "Gobble, Gobble";

		assertEquals(reverse(local.string), local.proxy.sayHello(local.string));
	</cfscript>
</cffunction>

<cffunction name="testDoubleNotORExpression" hint="test a double not OR expression" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};

		pointcut.setExpression("!@annotation(dostuff='true') OR !@annotation(dothings='true')");

		local.advisor = createObject("component", "coldspring.aop.PointcutAdvisor").init(pointcut, interceptor);

		proxyFactory.addAdvisor(local.advisor);

		local.proxy = proxyFactory.getProxy(hello);

		local.value = local.proxy.sayHello();

		assertEquals(reverse("hello"), local.value);

		assertEquals(reverse("Goodbye"), local.proxy.sayGoodbye());

		local.string = "Gobble, Gobble";

		assertEquals(reverse(local.string), local.proxy.sayHello(local.string));
	</cfscript>
</cffunction>

<cffunction name="testTargetExpression" hint="test a target expression" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};

		pointcut.setExpression("target(unittests.aop.com.Hello)");

		local.advisor = createObject("component", "coldspring.aop.PointcutAdvisor").init(pointcut, interceptor);

		proxyFactory.addAdvisor(local.advisor);

		//hello
		local.proxy = proxyFactory.getProxy(hello);

		local.value = local.proxy.sayHello();

		assertEquals(reverse("hello"), local.value);

		assertEquals(reverse("Goodbye"), local.proxy.sayGoodbye());

		local.string = "Gobble, Gobble";

		assertEquals(reverse(local.string), local.proxy.sayHello(local.string));

		//goodbye
		local.proxy = proxyFactory.getProxy(goodbye);

		local.value = local.proxy.sayHello();

		assertEquals("hello", local.value);

		assertEquals("Goodbye", local.proxy.sayGoodbye());

		local.string = "Gobble, Gobble";

		assertEquals(local.string, local.proxy.sayHello(local.string));
    </cfscript>
</cffunction>

<cffunction name="testSubPackageExpression" hint="test a target expression" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};

		pointcut.setExpression("within(unittests.aop..*)");

		local.advisor = createObject("component", "coldspring.aop.PointcutAdvisor").init(pointcut, interceptor);

		proxyFactory.addAdvisor(local.advisor);

		//hello
		local.proxy = proxyFactory.getProxy(hello);

		local.value = local.proxy.sayHello();

		assertEquals(reverse("hello"), local.value);

		assertEquals(reverse("Goodbye"), local.proxy.sayGoodbye());

		local.string = "Gobble, Gobble";

		assertEquals(reverse(local.string), local.proxy.sayHello(local.string));
    </cfscript>
</cffunction>

<cffunction name="testSubPackageExpressionSamePackage" hint="test a target expression" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};

		pointcut.setExpression("within(unittests.aop.com..*)");

		local.advisor = createObject("component", "coldspring.aop.PointcutAdvisor").init(pointcut, interceptor);

		proxyFactory.addAdvisor(local.advisor);

		//hello
		local.proxy = proxyFactory.getProxy(hello);

		local.value = local.proxy.sayHello();

		assertEquals(reverse("hello"), local.value);

		assertEquals(reverse("Goodbye"), local.proxy.sayGoodbye());

		local.string = "Gobble, Gobble";

		assertEquals(reverse(local.string), local.proxy.sayHello(local.string));

		//sub package
		local.hello = createObject("component", "unittests.aop.com.sub.Hello").init();

		local.proxy = proxyFactory.getProxy(local.hello);

		local.value = local.proxy.sayHello();

		assertEquals(reverse("hello"), local.value);

		assertEquals(reverse("Goodbye"), local.proxy.sayGoodbye());

		local.string = "Gobble, Gobble";

		assertEquals(reverse(local.string), local.proxy.sayHello(local.string));
    </cfscript>
</cffunction>

<cffunction name="testNotSubPackage" hint="test a target expression" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};

		pointcut.setExpression("within(unittests.NNN.com..*)");

		local.advisor = createObject("component", "coldspring.aop.PointcutAdvisor").init(pointcut, interceptor);

		proxyFactory.addAdvisor(local.advisor);

		//hello
		local.proxy = proxyFactory.getProxy(hello);

		local.value = local.proxy.sayHello();

		assertEquals("hello", local.value);

		assertEquals("Goodbye", local.proxy.sayGoodbye());

		local.string = "Gobble, Gobble";

		assertEquals(local.string, local.proxy.sayHello(local.string));
    </cfscript>
</cffunction>

<cffunction name="testPackageExpression" hint="test a target expression" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};

		pointcut.setExpression("within(unittests.aop.com.*)");

		local.advisor = createObject("component", "coldspring.aop.PointcutAdvisor").init(pointcut, interceptor);

		proxyFactory.addAdvisor(local.advisor);

		//hello
		local.proxy = proxyFactory.getProxy(hello);

		local.value = local.proxy.sayHello();

		assertEquals(reverse("hello"), local.value);

		assertEquals(reverse("Goodbye"), local.proxy.sayGoodbye());

		local.string = "Gobble, Gobble";

		assertEquals(reverse(local.string), local.proxy.sayHello(local.string));

		//sub package
		local.hello = createObject("component", "unittests.aop.com.sub.Hello").init();

		local.proxy = proxyFactory.getProxy(local.hello);

		local.value = local.proxy.sayHello();

		assertEquals("hello", local.value);

		assertEquals("Goodbye", local.proxy.sayGoodbye());

		local.string = "Gobble, Gobble";

		assertEquals(local.string, local.proxy.sayHello(local.string));
    </cfscript>
</cffunction>

<cffunction name="testNotPackage" hint="test a target expression" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};

		pointcut.setExpression("within(unittests.NNN.com.*)");

		local.advisor = createObject("component", "coldspring.aop.PointcutAdvisor").init(pointcut, interceptor);

		proxyFactory.addAdvisor(local.advisor);

		//hello
		local.proxy = proxyFactory.getProxy(hello);

		local.value = local.proxy.sayHello();

		assertEquals("hello", local.value);

		assertEquals("Goodbye", local.proxy.sayGoodbye());

		local.string = "Gobble, Gobble";

		assertEquals(local.string, local.proxy.sayHello(local.string));
    </cfscript>
</cffunction>

<cffunction name="testBadWithin" hint="Test a within expression that doesn't end in ..*/.*" access="public" returntype="void" output="false"
	mxunit:expectedException="coldspring.aop.expression.exception.InvalidExpressionException">
	<cfscript>
		var local = {};

		pointcut.setExpression("within(unittests.NNN.com)");

		//force the expressiont to be built.
		makePublic(pointcut, "buildExpressionPointcut");
		pointcut.buildExpressionPointcut();
    </cfscript>
</cffunction>

<cffunction name="testNegateTargetExpression" hint="test a target expression" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};

		pointcut.setExpression("!target(unittests.aop.com.Hello)");

		local.advisor = createObject("component", "coldspring.aop.PointcutAdvisor").init(pointcut, interceptor);

		proxyFactory.addAdvisor(local.advisor);

		local.proxy = proxyFactory.getProxy(hello);

		//hello
		local.value = local.proxy.sayHello();

		assertEquals("hello", local.value);

		assertEquals("Goodbye", local.proxy.sayGoodbye());

		local.string = "Gobble, Gobble";

		assertEquals(local.string, local.proxy.sayHello(local.string));

		//goodbye
		local.proxy = proxyFactory.getProxy(goodbye);

		local.value = local.proxy.sayHello();

		assertEquals(reverse("hello"), local.value);

		assertEquals(reverse("Goodbye"), local.proxy.sayGoodbye());

		local.string = "Gobble, Gobble";

		assertEquals(reverse(local.string), local.proxy.sayHello(local.string));
    </cfscript>
</cffunction>

<cffunction name="testBadExpressionParameter" hint="test an errornous message" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};

		//we will do this as a check exception, as we want to make sure the right message comes out.
		local.check = false;

		try
		{
			pointcut.setExpression("!@annotation(dostuff=true') AND !@annotation(dothings='true')");
			makePublic(pointcut, "buildExpressionPointcut");
			pointcut.buildExpressionPointcut();
		}
		catch(coldspring.aop.expression.exception.InvalidExpressionException exc)
		{
			local.check = true;

			assertEquals("Invalid expression syntax found near 'true')'", exc.message);
			assertEquals("At line 1, 21 an error occured: mismatched input 'true' expecting set null", exc.detail);
		}

		if(!local.check)
		{
			fail("This bad expression did not throw an error!");
		}
	</cfscript>
</cffunction>

<cffunction name="testBadExpressionTargetType" hint="test an errornous message" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};

		//we will do this as a check exception, as we want to make sure the right message comes out.
		local.check = false;

		try
		{
			pointcut.setExpression("@annotaion(dostuff='true')");
			makePublic(pointcut, "buildExpressionPointcut");
			pointcut.buildExpressionPointcut();
		}
		catch(coldspring.aop.expression.exception.InvalidExpressionException exc)
		{
			local.check = true;

			debug(exc);

			assertEquals("Invalid expression syntax found near 'on(dostuff='true')'", exc.message);
			assertEquals("At line 1, 8 an error occured: no viable alternative at input 'on(dostuff='true')'", exc.detail);
		}

		if(!local.check)
		{
			fail("This bad expression did not throw an error!");
		}
	</cfscript>
</cffunction>

<cffunction name="testExecutionSubPackage" hint="test a target expression" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};

		pointcut.setExpression("execution(public unittests.aop..*.*(..))");

		local.advisor = createObject("component", "coldspring.aop.PointcutAdvisor").init(pointcut, interceptor);

		proxyFactory.addAdvisor(local.advisor);

		//hello
		local.proxy = proxyFactory.getProxy(hello);

		local.value = local.proxy.sayHello();

		assertEquals(reverse("hello"), local.value);

		assertEquals(reverse("Goodbye"), local.proxy.sayGoodbye());

		local.string = "Gobble, Gobble";

		assertEquals(reverse(local.string), local.proxy.sayHello(local.string));
    </cfscript>
</cffunction>

<cffunction name="testExecutionClass" hint="test a target expression" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};

		pointcut.setExpression("execution(public unittests.aop.com.Hello.*(..))");

		local.advisor = createObject("component", "coldspring.aop.PointcutAdvisor").init(pointcut, interceptor);

		proxyFactory.addAdvisor(local.advisor);

		//hello
		local.proxy = proxyFactory.getProxy(hello);

		local.value = local.proxy.sayHello();

		assertEquals(reverse("hello"), local.value);

		assertEquals(reverse("Goodbye"), local.proxy.sayGoodbye());

		local.string = "Gobble, Gobble";

		assertEquals(reverse(local.string), local.proxy.sayHello(local.string));
    </cfscript>
</cffunction>

<cffunction name="testNotExecutionClass" hint="test a target expression" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};

		pointcut.setExpression("execution(public unittests.aop.com.Goodbye.*(..))");

		local.advisor = createObject("component", "coldspring.aop.PointcutAdvisor").init(pointcut, interceptor);

		proxyFactory.addAdvisor(local.advisor);

		//hello
		local.proxy = proxyFactory.getProxy(hello);

		local.value = local.proxy.sayHello();

		assertEquals("hello", local.value);

		assertEquals("Goodbye", local.proxy.sayGoodbye());

		local.string = "Gobble, Gobble";

		assertEquals(local.string, local.proxy.sayHello(local.string));
    </cfscript>
</cffunction>

<cffunction name="testExecutionSubPackageSamePackage" hint="test a target expression" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};

		pointcut.setExpression("execution(public unittests.aop.com..*.*(..))");

		local.advisor = createObject("component", "coldspring.aop.PointcutAdvisor").init(pointcut, interceptor);

		proxyFactory.addAdvisor(local.advisor);

		//hello
		local.proxy = proxyFactory.getProxy(hello);

		local.value = local.proxy.sayHello();

		assertEquals(reverse("hello"), local.value);

		assertEquals(reverse("Goodbye"), local.proxy.sayGoodbye());

		local.string = "Gobble, Gobble";

		assertEquals(reverse(local.string), local.proxy.sayHello(local.string));
    </cfscript>
</cffunction>

<cffunction name="testExecutionNotSubPackage" hint="test a target expression" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};

		pointcut.setExpression("execution(public unittests.aop.NNN..*.*(..))");

		local.advisor = createObject("component", "coldspring.aop.PointcutAdvisor").init(pointcut, interceptor);

		proxyFactory.addAdvisor(local.advisor);

		//hello
		local.proxy = proxyFactory.getProxy(hello);

		local.value = local.proxy.sayHello();

		assertEquals("hello", local.value);

		assertEquals("Goodbye", local.proxy.sayGoodbye());

		local.string = "Gobble, Gobble";

		assertEquals(local.string, local.proxy.sayHello(local.string));
    </cfscript>
</cffunction>

<cffunction name="testSingleMethodWithWildcard" hint="test a target expression" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};

		pointcut.setExpression("execution(public say*(..))");

		local.advisor = createObject("component", "coldspring.aop.PointcutAdvisor").init(pointcut, interceptor);

		proxyFactory.addAdvisor(local.advisor);

		//hello
		local.proxy = proxyFactory.getProxy(hello);

		local.value = local.proxy.sayHello();

		assertEquals(reverse("hello"), local.value);

		assertEquals(reverse("Goodbye"), local.proxy.sayGoodbye());

		local.string = "Gobble, Gobble";

		assertEquals(reverse(local.string), local.proxy.sayHello(local.string));
    </cfscript>
</cffunction>

<cffunction name="testSingleMethod" hint="test a target expression" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};

		pointcut.setExpression("execution(public sayHello(..))");

		local.advisor = createObject("component", "coldspring.aop.PointcutAdvisor").init(pointcut, interceptor);

		proxyFactory.addAdvisor(local.advisor);

		//hello
		local.proxy = proxyFactory.getProxy(hello);

		local.value = local.proxy.sayHello();

		assertEquals(reverse("hello"), local.value);

		assertEquals("Goodbye", local.proxy.sayGoodbye());

		local.string = "Gobble, Gobble";

		assertEquals(reverse(local.string), local.proxy.sayHello(local.string));
	</cfscript>
</cffunction>

<cffunction name="testClassWithMethodWithWildcard" hint="test a target expression" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};

		pointcut.setExpression("execution(public unittests.aop.com.Hello.say*(..))");

		local.advisor = createObject("component", "coldspring.aop.PointcutAdvisor").init(pointcut, interceptor);

		proxyFactory.addAdvisor(local.advisor);

		//hello
		local.proxy = proxyFactory.getProxy(hello);

		local.value = local.proxy.sayHello();

		assertEquals(reverse("hello"), local.value);

		assertEquals(reverse("Goodbye"), local.proxy.sayGoodbye());

		local.string = "Gobble, Gobble";

		assertEquals(reverse(local.string), local.proxy.sayHello(local.string));
    </cfscript>
</cffunction>

<cffunction name="testClassWithMethod" hint="test a target expression" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};

		pointcut.setExpression("execution(public unittests.aop.com.Hello.sayHello(..))");

		local.advisor = createObject("component", "coldspring.aop.PointcutAdvisor").init(pointcut, interceptor);

		proxyFactory.addAdvisor(local.advisor);

		//hello
		local.proxy = proxyFactory.getProxy(hello);

		local.value = local.proxy.sayHello();

		assertEquals(reverse("hello"), local.value);

		assertEquals("Goodbye", local.proxy.sayGoodbye());

		local.string = "Gobble, Gobble";

		assertEquals(reverse(local.string), local.proxy.sayHello(local.string));
	</cfscript>
</cffunction>

<cffunction name="testClassWithMethodWithAnyReturnType" hint="test a target expression" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};

		pointcut.setExpression("execution(public * unittests.aop.com.Hello.sayHello(..))");

		local.advisor = createObject("component", "coldspring.aop.PointcutAdvisor").init(pointcut, interceptor);

		proxyFactory.addAdvisor(local.advisor);

		//hello
		local.proxy = proxyFactory.getProxy(hello);

		local.value = local.proxy.sayHello();

		assertEquals(reverse("hello"), local.value);

		assertEquals("Goodbye", local.proxy.sayGoodbye());

		local.string = "Gobble, Gobble";

		assertEquals(reverse(local.string), local.proxy.sayHello(local.string));
	</cfscript>
</cffunction>

<cffunction name="testNotMethodWithWildCard" hint="test a target expression" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};

		pointcut.setExpression("execution(public sayG*(..))");

		local.advisor = createObject("component", "coldspring.aop.PointcutAdvisor").init(pointcut, interceptor);

		proxyFactory.addAdvisor(local.advisor);

		//hello
		local.proxy = proxyFactory.getProxy(hello);

		local.value = local.proxy.sayHello();

		assertEquals("hello", local.value);

		assertEquals(reverse("Goodbye"), local.proxy.sayGoodbye());

		local.string = "Gobble, Gobble";

		assertEquals(local.string, local.proxy.sayHello(local.string));
    </cfscript>
</cffunction>

<cffunction name="testBadExecutionScope" hint="Test an expression that starts with '*'" access="public" returntype="void" output="false"
	mxunit:expectedException="coldspring.aop.expression.exception.InvalidExpressionException">
	<cfscript>
		var local = {};

		pointcut.setExpression("execution(* unittests.aop.NNN..*.*(..))");

		//force the expressiont to be built.
		makePublic(pointcut, "buildExpressionPointcut");
		pointcut.buildExpressionPointcut();
    </cfscript>
</cffunction>

<cffunction name="testReturnPointcut" hint="test a exection() expression with a return pointcut" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};

		pointcut.setExpression("execution(public string say*(..))");

		local.advisor = createObject("component", "coldspring.aop.PointcutAdvisor").init(pointcut, interceptor);

		proxyFactory.addAdvisor(local.advisor);

		//hello
		local.proxy = proxyFactory.getProxy(hello);

		local.value = local.proxy.sayHello();

		assertEquals(reverse("hello"), local.value);

		assertEquals("Goodbye", local.proxy.sayGoodbye());

		local.string = "Gobble, Gobble";

		assertEquals(reverse(local.string), local.proxy.sayHello(local.string));
    </cfscript>
</cffunction>

<cffunction name="testArgumentsPointcut" hint="test a execution expression with arguments" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};

		pointcut.setExpression("execution(public string *(string))");

		local.advisor = createObject("component", "coldspring.aop.PointcutAdvisor").init(pointcut, interceptor);

		proxyFactory.addAdvisor(local.advisor);

		//hello
		local.proxy = proxyFactory.getProxy(hello);

		local.value = local.proxy.sayHello();

		assertEquals(reverse("hello"), local.value);

		assertEquals("Goodbye", local.proxy.sayGoodbye());

		local.string = "Gobble, Gobble";

		assertEquals(reverse(local.string), local.proxy.sayHello(local.string));
    </cfscript>
</cffunction>

<cffunction name="testNotArgumentsPointcut" hint="test a execution expression with arguments" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};

		pointcut.setExpression("execution(public string *(com.foo.Thing))");

		local.advisor = createObject("component", "coldspring.aop.PointcutAdvisor").init(pointcut, interceptor);

		proxyFactory.addAdvisor(local.advisor);

		//hello
		local.proxy = proxyFactory.getProxy(hello);

		local.value = local.proxy.sayHello();

		assertEquals("hello", local.value);

		assertEquals("Goodbye", local.proxy.sayGoodbye());

		local.string = "Gobble, Gobble";

		assertEquals(local.string, local.proxy.sayHello(local.string));
    </cfscript>
</cffunction>

<cffunction name="testArgumentsPointcutWildcard" hint="test a execution expression with arguments" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};

		pointcut.setExpression("execution(public string *(*))");

		local.advisor = createObject("component", "coldspring.aop.PointcutAdvisor").init(pointcut, interceptor);

		proxyFactory.addAdvisor(local.advisor);

		//hello
		local.proxy = proxyFactory.getProxy(hello);

		local.value = local.proxy.sayHello();

		assertEquals(reverse("hello"), local.value);

		assertEquals("Goodbye", local.proxy.sayGoodbye());

		local.string = "Gobble, Gobble";

		assertEquals(reverse(local.string), local.proxy.sayHello(local.string));
    </cfscript>
</cffunction>

<cffunction name="testNotArgumentsPointcutWildcard" hint="test a execution expression with arguments" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};

		pointcut.setExpression("execution(public string *(*, *))");

		local.advisor = createObject("component", "coldspring.aop.PointcutAdvisor").init(pointcut, interceptor);

		proxyFactory.addAdvisor(local.advisor);

		//hello
		local.proxy = proxyFactory.getProxy(hello);

		local.value = local.proxy.sayHello();

		assertEquals("hello", local.value);

		assertEquals("Goodbye", local.proxy.sayGoodbye());

		local.string = "Gobble, Gobble";

		assertEquals(local.string, local.proxy.sayHello(local.string));
    </cfscript>
</cffunction>


<cffunction name="testNoArguments" hint="test a execution expression with arguments" access="public" returntype="void" output="false">
	<cfscript>
		var local = {};

		pointcut.setExpression("execution(public string say*())");

		local.advisor = createObject("component", "coldspring.aop.PointcutAdvisor").init(pointcut, interceptor);

		proxyFactory.addAdvisor(local.advisor);

		//hello
		local.proxy = proxyFactory.getProxy(hello);

		local.value = local.proxy.sayStuff();

		assertEquals(reverse("Stuff"), local.value);

		local.value = local.proxy.sayHello();

		assertEquals("hello", local.value);

		assertEquals("Goodbye", local.proxy.sayGoodbye());

		local.string = "Gobble, Gobble";

		assertEquals(local.string, local.proxy.sayHello(local.string));
    </cfscript>
</cffunction>

<!------------------------------------------- PACKAGE ------------------------------------------->

<!------------------------------------------- PRIVATE ------------------------------------------->

</cfcomponent>