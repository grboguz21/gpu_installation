import torch

# is cuda activated?
print(f"CUDA: {torch.cuda.is_available()}")

# gpu device which is using
print(f"GPU: {torch.cuda.get_device_name(0)}")
