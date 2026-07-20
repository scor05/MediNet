<?php

namespace Tests\Unit;

use Illuminate\Container\Container;
use Illuminate\Contracts\Routing\ResponseFactory;
use Illuminate\Http\JsonResponse;
use PHPUnit\Framework\TestCase;

abstract class UnitTestCase extends TestCase
{
    protected function setUp(): void
    {
        parent::setUp();

        $responseFactory = $this->createStub(ResponseFactory::class);
        $responseFactory->method('json')->willReturnCallback(
            fn ($data = [], $status = 200, array $headers = [], $options = 0) => new JsonResponse($data, $status, $headers, $options)
        );

        $container = new Container;
        $container->instance(ResponseFactory::class, $responseFactory);
        Container::setInstance($container);
    }

    protected function tearDown(): void
    {
        Container::setInstance(null);

        parent::tearDown();
    }
}
