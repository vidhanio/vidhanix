# Liquid models on vortex

The service uses the upstream `llama-cpp` flake's Vulkan package, pinned in
`flake.lock`. Update it with `nix flake update llama-cpp`.

| API model ID   | Checkpoint | Context | Features                                  |
| -------------- | ---------- | ------- | ----------------------------------------- |
| `lfm3-1.7b`    | QAD Q4_0   | 256K    | Text, reasoning, tools, structured output |
| `lfm3-vl-2b`   | Q4_0       | 128K    | Images, reasoning, tools                  |
| `lfm3-omni-2b` | Q4_K_M     | 32K     | Text, images, audio input; no reasoning   |

The text model's official Q4_0 checkpoint uses quantization-aware distillation
to recover accuracy. Text and vision use Liquid's recommended sampling and
Q8 KV caches rather than further reducing the precision of an already small cache.
All three presets offload to the RX 9060 XT (`Vulkan0`), avoiding the slower
iGPU. One slot per model preserves the full advertised context for a request.
The router keeps at most one model loaded; switching models evicts the previous
one. Weights and matching vision/audio projectors download on first use. The
service's cache lives in its persistent `/var/cache/private` directory.

After activating the NixOS configuration, use the existing web UI at
<http://localhost:8080> or the OpenAI-compatible API:

```sh
curl http://localhost:8080/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{"model":"lfm3-1.7b","messages":[{"role":"user","content":"Hello!"}],"max_tokens":512}'
```

- Reasoning is returned in `message.reasoning_content` for text and vision.
  Old turns' reasoning is not preserved, following the checkpoint default.
- Pass function schemas in `tools`; parsed calls appear in `message.tool_calls`.
  The client must execute tools and return their results.
- Pass `response_format` with a JSON schema for constrained structured output.
- For math/STEM, override sampling per request with `temperature: 1.0`,
  `top_p: 0.95`, and `top_k: 20`.
- Send images as OpenAI `image_url` content parts to either model with vision support. Send audio
  as `input_audio` parts to the combined vision/audio model. This is not a promise of video support or
  realtime speech-to-speech: those require separate upstream/client support.
- Deferred tool search also requires the client to implement search and pass
  deferred schemas/tool references; it is not enabled by a server switch.

## Validation

The upstream Vulkan package was built and the generated presets tested on a
separate temporary server, without activating NixOS:

- Text: full 256K context, separated reasoning, parsed weather tool call, and
  constrained JSON output. Short-prompt generation measured about 122 tokens/s.
- Vision: loaded the matching projector and correctly identified a generated
  solid-red PNG; about 117 tokens/s on that short request.
- Combined vision/audio model: text, image, and WAV audio-input requests completed successfully.

These are smoke tests, not quality evaluations or long-context throughput
benchmarks. Speech generation and deferred tool search were not tested.

References: [release](https://www.liquid.ai/blog/lfm3),
[text](https://huggingface.co/LiquidAI/LFM3-1.7B-GGUF),
[vision](https://huggingface.co/LiquidAI/LFM3-VL-2B),
[omni](https://huggingface.co/LiquidAI/LFM3-Omni-2B-GGUF).
