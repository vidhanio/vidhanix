import sys

import gguf

base_path, donor_path, out_path = sys.argv[1:]
base = gguf.GGUFReader(base_path)
donor = gguf.GGUFReader(donor_path)
arch = base.fields[gguf.Keys.General.ARCHITECTURE].contents()

n_layer = base.fields[f"{arch}.block_count"].contents()
assert donor.fields[f"{arch}.block_count"].contents() == n_layer + 1
assert donor.fields[f"{arch}.nextn_predict_layers"].contents() == 1
mtp_prefix = f"blk.{n_layer}."
mtp = [t for t in donor.tensors if t.name.startswith(mtp_prefix)]
assert mtp and not any(t.name.startswith(mtp_prefix) for t in base.tensors)

writer = gguf.GGUFWriter(out_path, arch=arch, endianess=base.endianess)
for field in base.fields.values():
    if field.name == gguf.Keys.General.ARCHITECTURE or field.name.startswith("GGUF."):
        continue
    val_type = field.types[0]
    sub_type = field.types[-1] if val_type == gguf.GGUFValueType.ARRAY else None
    value = field.contents()
    if field.name == f"{arch}.block_count":
        value = n_layer + 1
    elif field.name == f"{arch}.attention.recurrent_layers":
        value = [*value, False]
    writer.add_key_value(field.name, value, val_type, sub_type=sub_type)
writer.add_key_value(f"{arch}.nextn_predict_layers", 1, gguf.GGUFValueType.UINT32)

tensors = [*base.tensors, *mtp]
for t in tensors:
    writer.add_tensor_info(
        t.name, t.data.shape, t.data.dtype, t.data.nbytes, t.tensor_type
    )
writer.write_header_to_file()
writer.write_kv_data_to_file()
writer.write_ti_data_to_file()
for t in tensors:
    writer.write_tensor_data(t.data, tensor_endianess=base.endianess)
writer.close()
