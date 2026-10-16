import bpy
import sys
import math
import os
from mathutils import Vector

def normalize_and_bake(input_path, output_path, target_length):
    print(f"\n==========================================")
    print(f"PROCESSING & BAKING: {input_path}")
    
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=input_path)
    
    mesh_objs = [obj for obj in bpy.context.scene.objects if obj.type == 'MESH']
    if not mesh_objs:
        print("NESSUNA MESH TROVATA!")
        return False
        
    # Calcola bounding box globale
    min_co = Vector((float('inf'), float('inf'), float('inf')))
    max_co = Vector((float('-inf'), float('-inf'), float('-inf')))
    
    for obj in mesh_objs:
        for corner in obj.bound_box:
            world_corner = obj.matrix_world @ Vector(corner)
            for i in range(3):
                min_co[i] = min(min_co[i], world_corner[i])
                max_co[i] = max(max_co[i], world_corner[i])
                
    orig_size = max_co - min_co
    orig_center = (min_co + max_co) * 0.5
    print(f"Orig Size: X={orig_size.x:.3f}, Y={orig_size.y:.3f}, Z={orig_size.z:.3f}")
    print(f"Orig Center: {orig_center}")
    
    # Trova asse lunghezza
    dims = [orig_size.x, orig_size.y, orig_size.z]
    max_dim_idx = dims.index(max(dims))
    max_dim_val = dims[max_dim_idx]
    scale_factor = target_length / max_dim_val
    print(f"Max dim: {max_dim_val:.3f} on axis {max_dim_idx}. Scale factor: {scale_factor:.6f}")
    
    root_empty = bpy.data.objects.new("BakeRoot", None)
    bpy.context.scene.collection.objects.link(root_empty)
    
    top_objs = [obj for obj in bpy.context.scene.objects if obj.parent is None and obj != root_empty]
    for obj in top_objs:
        obj.parent = root_empty
        
    root_empty.location = -orig_center
    root_empty.scale = Vector((scale_factor, scale_factor, scale_factor))
    
    # Se la dimensione maggiore è sull'asse X o Z, ruotiamo per allinearla a Y (lunghezza veicolo in Blender)
    if max_dim_idx == 0:
        root_empty.rotation_euler.z = math.pi * 0.5
    elif max_dim_idx == 2:
        root_empty.rotation_euler.x = math.pi * 0.5
        
    bpy.context.view_layer.update()
    
    # Seleziona tutte le mesh, stacca il parent applicando il transform e applica location/rotation/scale ai vertici
    bpy.ops.object.select_all(action='DESELECT')
    for obj in mesh_objs:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = mesh_objs[0]
    
    bpy.ops.object.parent_clear(type='CLEAR_KEEP_TRANSFORM')
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    
    # Rimuovi l'empty ormai vuoto
    bpy.data.objects.remove(root_empty, do_unlink=True)
    
    # Ricalcola nuovo AABB post-bake
    min_b = Vector((float('inf'), float('inf'), float('inf')))
    max_b = Vector((float('-inf'), float('-inf'), float('-inf')))
    for obj in mesh_objs:
        for corner in obj.bound_box:
            world_corner = obj.matrix_world @ Vector(corner)
            for i in range(3):
                min_b[i] = min(min_b[i], world_corner[i])
                max_b[i] = max(max_b[i], world_corner[i])
    new_size = max_b - min_b
    print(f"BAKED Size: X={new_size.x:.3f}, Y={new_size.y:.3f}, Z={new_size.z:.3f}")
    print(f"BAKED Min: {min_b}, Max: {max_b}")
    
    # Esporta GLB
    bpy.ops.export_scene.gltf(
        filepath=output_path,
        export_format='GLB',
        export_apply=True,
        export_materials='EXPORT',
        export_cameras=False,
        export_lights=False
    )
    print(f"ESPORTATO CORRETTAMENTE: {output_path}")
    return True

if __name__ == "__main__":
    base_dir = r"c:\Users\icopa\.gemini\antigravity\scratch\combat\godot_project\models"
    
    # 1. 1975 Porsche 911 930 Turbo (4.29m)
    normalize_and_bake(
        os.path.join(base_dir, "free_1975_porsche_911_930_turbo.glb"),
        os.path.join(base_dir, "porsche_930_turbo.glb"),
        target_length=4.29
    )
    
    # 2. Porsche 911 Carrera 4S (4.52m)
    normalize_and_bake(
        os.path.join(base_dir, "free_porsche_911_carrera_4s.glb"),
        os.path.join(base_dir, "porsche_carrera_4s.glb"),
        target_length=4.52
    )
    
    # 3. Lamborghini Countach LPI 800-4 (4.87m)
    normalize_and_bake(
        os.path.join(base_dir, "2021_lamborghini_countach_lpi_800-4.glb"),
        os.path.join(base_dir, "countach_lpi800.glb"),
        target_length=4.87
    )
