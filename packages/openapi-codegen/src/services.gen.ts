// This file is auto-generated by @hey-api/openapi-ts

import type { CancelablePromise } from './core/CancelablePromise';
import { OpenAPI } from './core/OpenAPI';
import { request as __request } from './core/request';
import type { $OpenApiTs } from './types.gen';

export class IntrospectionService {
    /**
     * OpenAPI description (this document)
     * @returns unknown OK
     * @throws ApiError
     */
    public static get(): CancelablePromise<$OpenApiTs['/']['get']['res'][200]> {
        return __request(OpenAPI, {
            method: 'GET',
            url: '/'
        });
    }
    
}