
/**
 * @file 	MultiHardwareTracer.cl
 * @brief 	Multi object, hardware-based, ray tracer source code.
 */

/** 
 * @brief Ray data structure.
 */
typedef struct {
	float3 point;		// Base point
	float3 direction;	// Normalized direction vector
} Ray;

/** 
 * @brief Vertex data.
 * This structure doesn't map portably to the Host.
 */
typedef struct {
	float3 coord;		// Vertex position
	float3 normal;		// Vertex normalized normal vector
	float2 tex;			// Vertex texture coordinate
} Vertex_;

/**
 * @brief Synthesis Element.
 */
typedef struct {
	float3 	point;		// Point of intersection
	float3	normal;		// Normal vector of the surface that collided with the ray.
	float	distance;	// Distance from the origin of the ray.
	int		material;	// Material index/id (will be defined later).
} SynthesisElement;

/** 
 * @brief Plane
 */
typedef struct {
	float3 point;
	float3 normal;
} Plane;

/** 
 * @brief Camera definition
 */
typedef struct {
    float3 position;
    float3 lookAt;
    float3 up;
} Camera;

/**
 * @brief 4x4 Matrix structure
 */
typedef struct {
    float4 rows[4];
} Matrix;


float3 transp(Matrix matrix, float3 vector) 
{
	float4 v = (float4)(vector, 1.0f);
    float4 result = {
        dot(matrix.rows[0], v),
        dot(matrix.rows[1], v),
        dot(matrix.rows[2], v),
        dot(matrix.rows[3], v)
    };
    
    return result.xyz;
}

float3 transv(Matrix matrix, float3 vector) 
{
	float4 v = (float4)(vector, 0.0f);
    float4 result = {
        dot(matrix.rows[0], v),
        dot(matrix.rows[1], v),
        dot(matrix.rows[2], v),
        dot(matrix.rows[3], v)
    };
    
    return result.xyz;
}

/*sample cube data*/
/*
constant Vertex vertices_[] =  {
    // Cara trasera
    {{-0.5f,   0.5f, -0.5f},   {0.0f, 0.0f, -1.0f},  {0.0f, 1.0f}},  // Izquierda,  Arriba,  Atras
    {{ 0.5f,   0.5f, -0.5f},   {0.0f, 0.0f, -1.0f},  {1.0f, 1.0f}},  // Derecha,    Arriba,  Atras
    {{-0.5f,  -0.5f, -0.5f},   {0.0f, 0.0f, -1.0f},  {0.0f, 0.0f}},  // Izquierda,  Abajo,   Atras
    {{ 0.5f,  -0.5f, -0.5f},   {0.0f, 0.0f, -1.0f},  {1.0f, 0.0f}},  // Derecha,    Abajo,   Atras

    // Cara derecha
    {{0.5f,   0.5f, -0.5f},   {1.0f, 0.0f, 0.0f},   {0.0f, 1.0f}}, // Derecha,     Arriba, Atras
    {{0.5f,   0.5f,  0.5f},   {1.0f, 0.0f, 0.0f},   {1.0f, 1.0f}}, // Derecha,     Arriba, Adelante
    {{0.5f,  -0.5f, -0.5f},   {1.0f, 0.0f, 0.0f},   {0.0f, 0.0f}}, // Derecha,     Abajo,  Atras
    {{0.5f,  -0.5f,  0.5f},   {1.0f, 0.0f, 0.0f},   {1.0f, 0.0f}}, // Derecha,     Abajo,  Adelante 

    // Cara delantera
    {{ 0.5f,   0.5f,  0.5f},   {0.0f, 0.0f, 1.0f},   {1.0f, 1.0f}},  // Derecha,     Arriba, Adelante
    {{-0.5f,   0.5f,  0.5f},   {0.0f, 0.0f, 1.0f},   {0.0f, 1.0f}},  // Izquierda,   Arriba, Adelante
    {{ 0.5f,  -0.5f,  0.5f},   {0.0f, 0.0f, 1.0f},   {1.0f, 0.0f}},  // Derecha,     Abajo,  Adelante
    {{-0.5f,  -0.5f,  0.5f},   {0.0f, 0.0f, 1.0f},   {0.0f, 0.0f}},  // Izquierda,   Abajo,  Adelante
    
    // Cara Izquierda
    {{-0.5f,   0.5f,  0.5f},  {-1.0f, 0.0f, 0.0f},   {1.0f, 1.0f}}, // Izquierda,   Arriba, Adelante
    {{-0.5f,   0.5f, -0.5f},  {-1.0f, 0.0f, 0.0f},   {0.0f, 1.0f}}, // Izquierda,   Arriba, Atras
    {{-0.5f,  -0.5f,  0.5f},  {-1.0f, 0.0f, 0.0f},   {1.0f, 0.0f}}, // Izquierda,   Abajo,  Adelante 
    {{-0.5f,  -0.5f, -0.5f},  {-1.0f, 0.0f, 0.0f},   {0.0f, 0.0f}}, // Izquierda,   Abajo,  Atras
    
    // Cara de Arriba
    {{-0.5f,   0.5f,   0.5f},  {0.0f, 1.0f, 0.0f},   {0.0f, 1.0f}}, // Izquierda,   Arriba, Adelante
    {{ 0.5f,   0.5f,   0.5f},  {0.0f, 1.0f, 0.0f},   {1.0f, 1.0f}}, // Derecha,     Arriba, Adelante
    {{-0.5f,   0.5f,  -0.5f},  {0.0f, 1.0f, 0.0f},   {0.0f, 0.0f}}, // Izquierda,   Arriba, Atras
    {{ 0.5f,   0.5f,  -0.5f},  {0.0f, 1.0f, 0.0f},   {1.0f, 0.0f}},  // Derecha,     Arriba, Atras
    
    // Cara Inferior
    {{ 0.5f,  -0.5f,   0.5f},  {0.0f, -1.0f, 0.0f},   {1.0f, 1.0f}}, // Derecha,     Abajo, Adelante
    {{-0.5f,  -0.5f,   0.5f},  {0.0f, -1.0f, 0.0f},   {0.0f, 1.0f}}, // Izquierda,   Abajo, Adelante
    {{ 0.5f,  -0.5f,  -0.5f},  {0.0f, -1.0f, 0.0f},   {1.0f, 0.0f}}, // Derecha,     Abajo, Atras
    {{-0.5f,  -0.5f,  -0.5f},  {0.0f, -1.0f, 0.0f},   {0.0f, 0.0f}}  // Izquierda,   Abajo, Atras
};

constant int indices_[] = {
    0 + 0,  0 + 1,  0 + 2,  0 + 1,  0 + 3,  0 + 2,
    4 + 0,  4 + 1,  4 + 2,  4 + 1,  4 + 3,  4 + 2, 
    8 + 0,  8 + 1,  8 + 2,  8 + 1,  8 + 3,  8 + 2, 
    12 + 0, 12 + 1, 12 + 2, 12 + 1, 12 + 3, 12 + 2, 
    16 + 0, 16 + 1, 16 + 2, 16 + 1, 16 + 3, 16 + 2, 
    20 + 0, 20 + 1, 20 + 2, 20 + 1, 20 + 3, 20 + 2
};

constant int indexCount_ = 36;
*/

constant Vertex_ vertices_[] =  {
    // Cara trasera
    {{-0.5f,   0.5f, -0.5f},   {0.0f, 0.0f, -1.0f},  {0.0f, 1.0f}},  // Izquierda,  Arriba,  Atras
    {{ 0.5f,   0.5f, -0.5f},   {0.0f, 0.0f, -1.0f},  {1.0f, 1.0f}},  // Derecha,    Arriba,  Atras
    {{-0.5f,  -0.5f, -0.5f},   {0.0f, 0.0f, -1.0f},  {0.0f, 0.0f}},  // Izquierda,  Abajo,   Atras
    {{ 0.5f,  -0.5f, -0.5f},   {0.0f, 0.0f, -1.0f},  {1.0f, 0.0f}},  // Derecha,    Abajo,   Atras

	// Cara derecha
    {{0.5f,   0.5f, -0.5f},   {1.0f, 0.0f, 0.0f},   {0.0f, 1.0f}}, // Derecha,     Arriba, Atras
    {{0.5f,   0.5f,  0.5f},   {1.0f, 0.0f, 0.0f},   {1.0f, 1.0f}}, // Derecha,     Arriba, Adelante
    {{0.5f,  -0.5f, -0.5f},   {1.0f, 0.0f, 0.0f},   {0.0f, 0.0f}}, // Derecha,     Abajo,  Atras
    {{0.5f,  -0.5f,  0.5f},   {1.0f, 0.0f, 0.0f},   {1.0f, 0.0f}}, // Derecha,     Abajo,  Adelante 

	// Cara delantera
    {{ 0.5f,   0.5f,  0.5f},   {0.0f, 0.0f, 1.0f},   {1.0f, 1.0f}},  // Derecha,     Arriba, Adelante
    {{-0.5f,   0.5f,  0.5f},   {0.0f, 0.0f, 1.0f},   {0.0f, 1.0f}},  // Izquierda,   Arriba, Adelante
    {{ 0.5f,  -0.5f,  0.5f},   {0.0f, 0.0f, 1.0f},   {1.0f, 0.0f}},  // Derecha,     Abajo,  Adelante
    {{-0.5f,  -0.5f,  0.5f},   {0.0f, 0.0f, 1.0f},   {0.0f, 0.0f}},  // Izquierda,   Abajo,  Adelante
};

constant int indices_[] = {
    0 + 0,  0 + 1,  0 + 2,  0 + 1,  0 + 3,  0 + 2,
	4 + 0,  4 + 1,  4 + 2,  4 + 1,  4 + 3,  4 + 2, 
	8 + 0,  8 + 1,  8 + 2,  8 + 1,  8 + 3,  8 + 2, 
};

constant int indexCount_ = 18;


/**
 * @brief Ray buffer generator kernel
 */

int coordToIndex(int x, int y, int width, int height) 
{
	return y*width + x;
}

Ray castRayFromMatrix(const float2 screenCoord, const float2 screenSize, const float2 sample, const Matrix viewMatrix, const Matrix invViewMatrix) 
{
	float2 coordsf = screenCoord + sample;

	float3 cam_pos = {0.0f, 0.0f, 0.0f};
	float3 cam_up = {0.0f, 1.0f, 0.0f};
	float3 cam_dir = {0.0f, 0.0f, 1.0f};
    float3 cam_right = cross(cam_up, cam_dir);
    
    float2 normalized_coords = (coordsf / (screenSize - (float2)(1.0f, 1.0f)) ) - (float2)(0.5f, 0.5f);
    float3 image_point = normalized_coords.x * cam_right + normalized_coords.y * cam_up + cam_pos + cam_dir;
    
    Ray ray = {
        cam_pos, 
        normalize(image_point - cam_pos) + (float3)(sample, 0.0f)
    };
    
    return ray;
}

/**
 * @brief Cast a perspective ray from the camera
 */
Ray castRay(const Camera *camera, const float2 screenCoord, const float2 screenSize, const float2 sample)
{
    float2 coordsf = screenCoord + sample;

	float3 cam_pos = camera->position;
	
	float3 cam_up = camera->up;	// assume a normalized vector
	float3 cam_dir = normalize(camera->lookAt - cam_pos);
    float3 cam_right = normalize(cross(cam_up, cam_dir));
    
    float2 normalized_coords = (coordsf / (screenSize - (float2)(1.0f, 1.0f)) ) - (float2)(0.5f, 0.5f);
    float3 image_point = normalized_coords.x * cam_right + normalized_coords.y * cam_up + cam_pos + cam_dir;
    
    Ray ray = {
        cam_pos, 
        normalize(image_point - cam_pos) + (float3)(sample, 0.0f)
    };
    
    return ray;
}

kernel void GenerateRays (
	global Ray *rays, 
	float camPosX, float camPosY, float camPosZ,
	float camLookAtX, float camLookAtY, float camLookAtZ, 
	float camUpX, float camUpY, float camUpZ,
	int screenWidth, int screenHeight) 
{
	int x = get_global_id(0);
	int y = get_global_id(1);
	
	int i = coordToIndex(x, y, screenWidth, screenHeight);
	
	float2 screenCoord = {(float)x, (float)y};
	float2 screenSize = {(float)screenWidth, (float)screenHeight};

	const Camera camera = {
		{camPosX, camPosY, camPosZ},
		{camLookAtX, camLookAtY, camLookAtZ},
		{camUpX, camUpY, camUpZ},
	};
	
    *(rays + i) = castRay(&camera, screenCoord, screenSize, (float2)(0.0f, 0.0f));
}

/**
 * @brief Explain itself.
 */
kernel void GenerateRaysFromWorldMatrix (
    global Ray *rays, 
    global float *viewBuffer,
    int screenWidth, int screenHeight)
{
    int x = get_global_id(0);
    int y = get_global_id(1);
    
    int i = coordToIndex(x, y, screenWidth, screenHeight);
    
    float2 screenCoord = {(float) x, (float)y};
    float2 screenSize = {(float)screenWidth, (float)screenHeight};
    
	Matrix viewMatrix		= *((global Matrix*)viewBuffer + 0 );
	Matrix viewInvMatrix	= *((global Matrix*)viewBuffer + 16);

	Ray ray = castRayFromMatrix(screenCoord, screenSize, (float2)(0.0f, 0.0f), viewMatrix, viewInvMatrix);

    *(rays + i) = ray;
}

/**
 * @brief Compute a synthesis element
 */
void computeElementPlane(SynthesisElement *out, Ray ray, Plane plane) 
{
	float a = dot(plane.normal, plane.point - ray.point);
	float b = dot(plane.normal, ray.direction);
	float distance = a / b;
	
	if (distance > 0.0f) {
		out->distance = distance;
		out->normal = plane.normal;
		out->point = ray.point + ray.direction * distance;
	}
}

/**
 * @brief Compute the triple dot product between three vectors.
 */
float triple(float3 a, float3 b, float3 c) 
{
	return dot(a, cross(b, c));
}

/**
 * @brief Compute a synthesis element for the specified triangle
 */
void computeElementTriangle(SynthesisElement *element, Ray ray, float3 p1, float3 p2, float3 p3, float3 normal) 
{
	const Plane plane = {
		(p1 + p2 + p3) * (1.0f/3.0f), 
		normal
	};
	
	SynthesisElement tempElement = {{0.0f, 0.0f, 0.0f}, {0.0f, 0.0f, 0.0f}, 0.0f, 0};

	computeElementPlane(&tempElement, ray, plane);
    if (tempElement.distance <= 0.0f) {
        return;
    }

	float3 p = ray.point;
	float3 q = tempElement.point;

	float3 pq = q - p;
	float3 pa = p1 - p;
	float3 pb = p2 - p;
	float3 pc = p3 - p;

	float u = triple(pq, pc, pb);
	float v = triple(pq, pa, pc);
	float w = triple(pq, pb, pa);
	
	if (u > 0.0f && v > 0.0f && w > 0.0f) {
		*element = tempElement;
	}
}

/**
 * @brief Compute a synthesis element from a mesh subset
 */
void computeElementMeshSubset (
    global SynthesisElement *element, Ray ray, 
    global float *vertices, global int *indices, int indexCount, int materialIndex)
{
	const int VertexSize = 32/4;	// = sizeof(exeng::Vertex)
	const int CoordOffset = 0;
	const int NormalOffset = 12/4;
	const int TexCoordOffset = 24/4;

	// global uchar *vertexData = (global uchar*)vertices;
    global float *vertexData = vertices;

	SynthesisElement bestElement = {{0.0f, 0.0f, 0.0f}, {0.0f, 0.0f, 0.0f}, 0.0f, 0};
	SynthesisElement currentElement = {{0.0f, 0.0f, 0.0f}, {0.0f, 0.0f, 0.0f}, 0.0f, 0};
	
	bestElement.distance = FLT_MAX;
	
	indexCount = indexCount_;

	for (int i=0; i<indexCount; i+=3) {
		float3 coord1 = vertices_[indices_[i + 0]].coord;
		float3 coord2 = vertices_[indices_[i + 1]].coord;
		float3 coord3 = vertices_[indices_[i + 2]].coord;
		float3 normal = vertices_[indices_[i + 0]].normal;
		
        /*
        float3 p1		= *(global float3*)(vertexData + VertexSize*indices[i + 0] + CoordOffset);
		float3 p2		= *(global float3*)(vertexData + VertexSize*indices[i + 1] + CoordOffset);
		float3 p3		= *(global float3*)(vertexData + VertexSize*indices[i + 2] + CoordOffset);
		float3 normal	= *(global float3*)(vertexData + VertexSize*indices[i + 0] + NormalOffset);
        */

		/*
		// render data from geometry mesh
        global float* vertex1Ptr = vertexData + VertexSize*indices[i + 0];
        global float* vertex2Ptr = vertexData + VertexSize*indices[i + 1];
        global float* vertex3Ptr = vertexData + VertexSize*indices[i + 2];
        global float* normalPtr = vertexData + VertexSize*indices[i + 0] + NormalOffset;
        
		float3 coord1 = {vertex1Ptr[0], vertex1Ptr[1], vertex1Ptr[2]};
		float3 coord2 = {vertex2Ptr[0], vertex2Ptr[1], vertex2Ptr[2]};
		float3 coord3 = {vertex3Ptr[0], vertex3Ptr[1], vertex3Ptr[2]};
		float3 normal = {normalPtr[0], normalPtr[1], normalPtr[2]};
		*/

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

kernel void ClearSynthesisData(global SynthesisElement *synthesisBuffer, int screenWidth, int screenHeight) 
{
    int x = get_global_id(0);
    int y = get_global_id(1);

    int i = coordToIndex(x, y, screenWidth, screenHeight);
    
	const SynthesisElement element = {{0.0f, 0.0f, 0.0f}, {0.0f, 0.0f, 0.0f}, 0.0f, 0};

	synthesisBuffer[i] = element;
}

/**
 * @brief Generate all the synthesis data to render a single object
 * This kernel compute the synthesis data (data needed for synthesize the final image) for the ray tracer for a 
 * single mesh subset data. It must be called multiple times, one for each meshSubset, to render a complete scene.
 */
kernel void ComputeSynthesisData (
	global SynthesisElement *synthesisBuffer, global Ray *rays, int screenWidth, int screenHeight,
	global float *vertices, global int *indices, int indexCount, int materialIndex, global float *localTransform)
{
	int x = get_global_id(0);
	int y = get_global_id(1);

	int i = coordToIndex(x, y, screenWidth, screenHeight);
    
	global Matrix *transforms = (global Matrix*)localTransform;

	Ray ray = rays[i];
	ray.point		= transp(transforms[1], ray.point);
	ray.direction	= transv(transforms[1], ray.direction);

	computeElementMeshSubset(&synthesisBuffer[i], ray, vertices, indices, indexCount, materialIndex);
}

/**
 * @brief Synthetize the final image.
 * 
 * The image is synthetized by using the different materials 
 */
kernel void SynthetizeImage (
    write_only image2d_t image, 
    global SynthesisElement *synthesisBuffer, global Ray *rays, int screenWidth, int screenHeight, 
    int materialSize, global float *materialData)
{
	int x = get_global_id(0);
	int y = get_global_id(1);
	int i = coordToIndex(x, y, screenWidth, screenHeight);
    
	Ray ray = rays[i];
	SynthesisElement synthElement = synthesisBuffer[i];
    
	const float4 white = {1.0f, 1.0f, 1.0f, 1.0f};
	float4 color = {0.0f, 0.0f, 0.0f, 0.0f};
	
	/*
	if (synthElement.distance > 0.0f) {
		const int materialIndex = synthElement.material;
		
		// color = *((global float4 *)(materialData + (materialIndex*materialSize)));
		// color = color * fabs(dot(ray.direction, synthElement.normal));

		color = white;
		color = color * fabs(dot(ray.direction, synthElement.normal));
	}
	*/
	
	if (x == 0) {
		color.x = 0.0f;
	} else {
		color.x = 1.0f;
	}

	color.y = 1.0f;
	color.z = 1.0f;
	color.w = 1.0f;

	write_imagef (image, (int2)(x, y), color);
}

kernel void GetStructuresSize(global int* out) 
{
	out[0] = sizeof(Ray);
	out[1] = sizeof(SynthesisElement);
}
