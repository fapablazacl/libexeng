
/**
 * @file 	MultiHardwareTracer.cl
 * @brief 	Multi object, hardware-based, ray tracer source code.
 */

/** 
 * @brief ray_t data structure.
 */
typedef struct {
	float4 point;		// Base point
	float4 direction;	// Normalized direction vector
} ray_t;

/** 
 * @brief vertex_t data.
 * This structure doesn't map portably to the Host.
 */
typedef struct {
	float4 coord;		// vertex coordinate
	float4 normal;		// vertex normal
	float4 tex;			// vertex texture coordinate
} vertex_t;

/**
 * @brief triangle_t structure
 */
typedef struct {
	float4 p[3];		// 
	float4 n;
} triangle_t;

/**
 * @brief Synthesis Element.
 */
typedef struct {
	float4 	point;		// Point of intersection
	float4	normal;		// Normal vector of the surface that collided with the ray.
	float	distance;	// Distance from the origin of the ray.
	int		material;	// Material index/id (will be defined later).
} SynthesisElement;

/** 
 * @brief plane_t
 */
typedef struct {
	float4 point;
	float4 normal;
} plane_t;

/** 
 * @brief camera_t definition
 */
typedef struct {
    float4 position;
    float4 look_at;
    float4 up;
} camera_t;

/**
 * @brief 4x4 matrix_t structure
 */
typedef float4 matrix_t[4];

float4 trans(matrix_t matrix, float4 vector) {
    const float4 result = {
        dot(matrix[0], vector),
        dot(matrix[1], vector),
        dot(matrix[2], vector),
        dot(matrix[3], vector)
    };
    
    return result;
}

inline int offset2(int x, int y, int width, int height) {
	return y*width + x;
}

/**
 * @brief Cast a perspective ray from the camera
 */
ray_t cast(const camera_t *camera, const float2 screenCoord, const float2 screenSize, const float2 sample) {
    
	const float4 cam_pos = camera->position;
	const float4 cam_up = camera->up;	// assume a normalized vector
	const float4 cam_dir = normalize(camera->look_at - cam_pos);
	const float4 cam_right = normalize(cross(cam_dir, cam_up));
    
	const float2 coordsf = screenCoord + sample;
    const float2 nc = (coordsf / (screenSize - (float2)(1.0f, 1.0f)) ) - (float2)(0.5f, 0.5f);

    const float4 image_point = nc.x*cam_right + nc.y*cam_up + cam_pos + cam_dir;
    
    const ray_t ray = {
        cam_pos, 
        normalize(image_point - cam_pos)
    };
    
    return ray;
}

__kernel void GenerateRays (
	global ray_t *rays, 
	float camPosX, float camPosY, float camPosZ,
	float camLookAtX, float camLookAtY, float camLookAtZ, 
	float camUpX, float camUpY, float camUpZ) 
{
	const int x = get_global_id(0);
	const int y = get_global_id(1);
	const int w = get_global_size(0);
	const int h = get_global_size(1);

	const int i = offset2(x, y, w, h);
	
	const float2 screenCoord = {(float)x, (float)y};
	const float2 screenSize = {(float)w, (float)h};

	const camera_t camera = {
		{camPosX, camPosY, camPosZ, 1.0f},
		{camLookAtX, camLookAtY, camLookAtZ, 1.0f},
		{camUpX, camUpY, camUpZ, 0.0f},
	};
	
    rays[i] = cast(&camera, screenCoord, screenSize, (float2)(0.0f, 0.0f));
}

void se_validate(SynthesisElement *element, float factor) {
	element->point *= factor;
	element->normal *= factor;
	element->distance *= factor;
}

/**
 * @brief Compute a synthesis element
 */
SynthesisElement compute_se_plane(const ray_t *ray, const plane_t *plane) {

	const float4 pp = plane->point;
	const float4 pn = plane->normal;
	const float4 rp = ray->point;
	const float4 rd = ray->direction;

	const float a = dot(pn, pp - rp);
	const float b = dot(pn, rd);
	const float d = a / b;

	const int test = -(isgreater(d, 0.0f) && isfinite(d));
	const int4 test4 = (int4)test;
	
	SynthesisElement st = {
		select(0.0f, (rp + rd * d), test4),
		select(0.0f, pn, test4), 
		select(0.0f, d, test),
		0
	};
	
	return st;
}

/**
 * @brief Compute the triple dot product between three vectors.
 */
float triple(float4 a, float4 b, float4 c) 
{
	return dot(a, cross(b, c));
}

/**
 * @brief Compute a synthesis element for the specified triangle
 */
SynthesisElement compute_se_triangle(ray_t ray, float4 p1, float4 p2, float4 p3, float4 normal) 
{
	const plane_t plane = {
		(p1 + p2 + p3) * (1.0f/3.0f), 
		normal
	};
	
	SynthesisElement se = compute_se_plane(&ray, &plane);
	
	const float factor_plane = (se.distance > 0.0f);

	const float4 p = ray.point;
	const float4 q = se.point;

	const float4 pq = factor_plane*(q - p);
	const float4 pa = p1 - p;
	const float4 pb = p2 - p;
	const float4 pc = p3 - p;

	const float u = triple(pq, pc, pb);
	const float v = triple(pq, pa, pc);
	const float w = triple(pq, pb, pa);
	
	const float factor_triangle = (u > 0.0f && v > 0.0f && w > 0.0f);

	se_validate(&se, factor_triangle);

	return se;
}

/**
 * @brief Compute a synthesis element from a mesh subset
 */
void computeElementMeshSubset (
    global SynthesisElement *element, ray_t ray, 
    global float *vertices, global int *indices, int indexCount, int materialIndex)
{
	// const int VertexSize = 32/4;	// = sizeof(xe::vertex_t)
	// const int CoordOffset = 0;
	// const int NormalOffset = 12/4;
	// const int TexCoordOffset = 24/4;
    global vertex_t *vertexData = (global vertex_t *)vertices;

	SynthesisElement best_se = {{0.0f, 0.0f, 0.0f, 0.0f}, {0.0f, 0.0f, 0.0f, 0.0f}, 0.0f, 0};
	SynthesisElement se = {{0.0f, 0.0f, 0.0f, 0.0f}, {0.0f, 0.0f, 0.0f, 0.0f}, 0.0f, 0};
	
	best_se.distance = FLT_MAX;
	
	for (int i=0; i<indexCount; i+=3) {

		// render data from geometry mesh
        // global float* vertex1Ptr = vertexData + VertexSize*indices[i + 0];
        // global float* vertex2Ptr = vertexData + VertexSize*indices[i + 1];
        // global float* vertex3Ptr = vertexData + VertexSize*indices[i + 2];
        // global float* normalPtr = vertexData + VertexSize*indices[i + 0] + NormalOffset;
		// 
		// float4 coord1 = {vertex1Ptr[0], vertex1Ptr[1], vertex1Ptr[2], 0.0f};
		// float4 coord2 = {vertex2Ptr[0], vertex2Ptr[1], vertex2Ptr[2], 0.0f};
		// float4 coord3 = {vertex3Ptr[0], vertex3Ptr[1], vertex3Ptr[2], 0.0f};
		// float4 normal = {normalPtr[0], normalPtr[1], normalPtr[2], 1.0f};

		float4 coord1 = vertexData[indices[i + 0]].coord;
		float4 coord2 = vertexData[indices[i + 1]].coord;
		float4 coord3 = vertexData[indices[i + 2]].coord;
		float4 normal = vertexData[indices[i + 0]].normal;
		
		se = compute_se_triangle(ray, coord1, coord2, coord3, normal);
		
		const int	test = -(se.distance>0.0f && se.distance<best_se.distance);
		const int4	test4 = test;
		best_se.point		= select(best_se.point,		se.point,		test4);
		best_se.normal		= select(best_se.normal,	se.normal,		test4);
		best_se.distance	= select(best_se.distance,	se.distance,	test);
	}
	
	const int test 
		= -((best_se.distance>0.0f && best_se.distance!=FLT_MAX) 
		&& (element->distance==0.0f || best_se.distance<element->distance));
	
	const int4 test4 = (int4)test;

	element->point		= select(element->point,	best_se.point,		test4);
	element->normal		= select(element->normal,	best_se.normal,		test4);
	element->distance	= select(element->distance, best_se.distance,	test);
	element->material	= select(element->material, materialIndex,		test);
}


/*
void computeElementMeshSubset (
    global SynthesisElement *element, ray_t ray, 
    global float *vertices, global int *indices, int indexCount, int materialIndex)
{
	const int VertexSize = 32/4;	// = sizeof(xe::vertex_t)
	const int CoordOffset = 0;
	const int NormalOffset = 12/4;
	const int TexCoordOffset = 24/4;

    global float *vertexData = vertices;

	SynthesisElement bestElement = {{0.0f, 0.0f, 0.0f, 0.0f}, {0.0f, 0.0f, 0.0f, 0.0f}, 0.0f, 0};
	SynthesisElement currentElement = {{0.0f, 0.0f, 0.0f, 0.0f}, {0.0f, 0.0f, 0.0f, 0.0f}, 0.0f, 0};
	
	bestElement.distance = FLT_MAX;
	
	for (int i=0; i<indexCount; i+=3) {

		// render data from geometry mesh
        global float* vertex1Ptr = vertexData + VertexSize*indices[i + 0];
        global float* vertex2Ptr = vertexData + VertexSize*indices[i + 1];
        global float* vertex3Ptr = vertexData + VertexSize*indices[i + 2];
        global float* normalPtr = vertexData + VertexSize*indices[i + 0] + NormalOffset;
        
		float4 coord1 = {vertex1Ptr[0], vertex1Ptr[1], vertex1Ptr[2], 0.0f};
		float4 coord2 = {vertex2Ptr[0], vertex2Ptr[1], vertex2Ptr[2], 0.0f};
		float4 coord3 = {vertex3Ptr[0], vertex3Ptr[1], vertex3Ptr[2], 0.0f};
		float4 normal = {normalPtr[0], normalPtr[1], normalPtr[2], 1.0f};
		
		computeElementTriangle(&currentElement, ray, coord1, coord2, coord3, normal);
		
		if (currentElement.distance>0.0f && currentElement.distance<bestElement.distance) {
		 	bestElement = currentElement;
		}
	}
	
	if (bestElement.distance > 0.0f && bestElement.distance != FLT_MAX) {
		if (element->distance==0.0f || bestElement.distance<element->distance) {
			*element = bestElement;
			element->material = materialIndex;
		}
    }
}
*/

__kernel void ClearSynthesisData(global SynthesisElement *synthesisBuffer) 
{
	const int w = get_global_size(0);
    const int h = get_global_size(1);
    const int x = get_global_id(0);
    const int y = get_global_id(1);
    const int i = offset2(x, y, w, h);

	const SynthesisElement element = {
		{0.0f, 0.0f, 0.0f, 0.0f},	// Point
		{0.0f, 0.0f, 0.0f, 0.0f},	// Normal
		0.0f,						// Distance
		0							// MaterialIndex
	};

	synthesisBuffer[i] = element;
}

/**
 * @brief Generate all the synthesis data to render a single object
 * This __kernel compute the data needed for synthesize the final image for the ray tracer of a 
 * single mesh subset data. It must be called multiple times, one for each meshSubset of each mesh, to render a complete scene.
 */
__kernel void ComputeSynthesisData (
	__global SynthesisElement *synthesisBuffer, 
	__global ray_t *rays, 
	__global float *vertices, 
	__global int *indices, 
	int indexCount, 
	int materialIndex, 
	__global matrix_t *transforms,
	__global float2 *samples, 
	const int sample_count)
{
	const int x = get_global_id(0);
	const int y = get_global_id(1);
	const int w = get_global_size(0);
	const int h = get_global_size(1);

	const int i = offset2(x, y, w, h);
    
	ray_t ray = rays[i];
	// ray.point		= trans(transforms[0], ray.point);
	// ray.direction	= trans(transforms[1], ray.direction);

	computeElementMeshSubset(&synthesisBuffer[i], ray, vertices, indices, indexCount, materialIndex);
}

/**
 * @brief Generate all the synthesis data to render a single object
 * This kernel compute the data needed for synthesize the final image for the ray tracer of a 
 * single mesh subset data. It must be called multiple times, one for each meshSubset of each mesh, to render a complete scene.
 */
__kernel void ComputeSynthesisData2 (
	__global SynthesisElement *synthesisBuffer,
	__global const float *vertices, __global const int *indices, const int indexCount, const int materialIndex, 
	__global const float2 *samples, const int sampleCount, 
	__global float *transforms)
{
	const int x = get_global_id(0);
	const int y = get_global_id(1);
	const int w = get_global_size(0);
	const int h = get_global_size(1);

	const int synthesisIndex = offset2(x, y, w, h);

}

/**
 * @brief Synthetize the final image.
 * 
 * The image is synthetized by using the different materials 
 */
__kernel void SynthetizeImage (
    __write_only image2d_t image, 
    __global SynthesisElement *synthesisBuffer, 
	__global ray_t *rays, 
    int materialSize, global float *materialData)
{
	const int w = get_global_size(0);
	const int h = get_global_size(1);
	const int x = get_global_id(0);
	const int y = get_global_id(1);
	const int i = offset2(x, y, w, h);
    
	const ray_t ray = rays[i];
	const SynthesisElement synthElement = synthesisBuffer[i];
    
	const float4 color = *((global float4 *)(materialData + synthElement.material*materialSize));
	const float4 finalColor = color * fabs(dot(ray.direction, synthElement.normal));

	write_imagef (image, (int2)(x, y), finalColor);
}

__kernel void GetStructuresSize(global int* out) 
{
	out[0] = sizeof(ray_t);
	out[1] = sizeof(SynthesisElement);
	out[2] = sizeof(vertex_t);
}
