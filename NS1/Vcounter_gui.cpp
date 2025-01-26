#include <imgui.h>
#include <backends/imgui_impl_sdl2.h>
#include <backends/imgui_impl_opengl3.h>
#include <SDL2/SDL.h>
#include <GL/glew.h> // Use GLEW for OpenGL function loading
#include "Vcounter.h"
Vcounter *top = NULL;
vluint64_t main_time = 0, last_step = 0;
static bool clk, reset, autoreset, run = true, autostep = true, quit;
static int step, step_time = 10, inc = 1;
void init_top() { if (!top) top = new Vcounter; }
void handle_key_event(SDL_Event& event) {
    if (event.type == SDL_KEYDOWN) {
        if (event.key.keysym.sym == SDLK_c) { clk = !clk; }
        else if (event.key.keysym.sym == SDLK_r) { reset = !reset; }
        else if (event.key.keysym.sym == SDLK_s) { step = 2; }
        else if (event.key.keysym.sym == SDLK_a) { autostep = !autostep; }
        else if (event.key.keysym.sym == SDLK_SPACE) { run = !run; }
    }
}
void render_gui() {
    ImGui::Begin("counter");
    ImGui::Checkbox("Run", &run);
    ImGui::SameLine();if (ImGui::Button("Quit")) { quit = true; }
    ImGui::SameLine();ImGui::Checkbox("AutoStep", &autostep);
    ImGui::SameLine();if (ImGui::Button("Step")) { step = 2; }
    ImGui::SameLine();ImGui::Text("step=%d", step);
    ImGui::SameLine();ImGui::Text("main_time %ld, Vtime=%ld", main_time, Verilated::time());
    ImGui::SliderInt("StepTime", &step_time, 1, 10);
    ImGui::SameLine();ImGui::Text("last_step=%ld", last_step);
    ImGui::Checkbox("clk", &clk);
    ImGui::SameLine();ImGui::Checkbox("AutoReset", &autoreset);
    ImGui::SameLine();if (ImGui::Button("Reset")) { reset = true; }
    if ((main_time++>=(last_step+step_time)) && run) {
        if (step) { clk = !clk; }
        top->clk = clk;
        top->reset = reset;
        top->eval();
        Verilated::timeInc(inc);
        if (step) { step--; }
        if (autostep && !step) { step = 2; }
        reset = false;
        if (autoreset) reset = true;
        last_step = main_time;
    }
    ImGui::SameLine();ImGui::Text("out %d", top->out);
    ImGui::End();
}
////////////////////////////////////////////////////////////////////////////////
int main() {
    init_top();
    if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_TIMER | SDL_INIT_GAMECONTROLLER) != 0) {
        printf("Error: %s\n", SDL_GetError());
        return -1;
    }
    SDL_Window* window = SDL_CreateWindow("Dear ImGui Example", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 800, 600, SDL_WINDOW_OPENGL | SDL_WINDOW_RESIZABLE);
    if (!window) {
        printf("Error: %s\n", SDL_GetError());
        return -1;
    }
    SDL_GLContext gl_context = SDL_GL_CreateContext(window);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 2);
    SDL_GL_SetSwapInterval(1); // Enable vsync
    if (glewInit() != GLEW_OK) {
        printf("Failed to initialize GLEW\n");
        return -1;
    }
    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGuiIO& io = ImGui::GetIO(); (void)io;
    ImGui::StyleColorsDark(); // Use dark style
    ImGui_ImplSDL2_InitForOpenGL(window, gl_context);
    ImGui_ImplOpenGL3_Init("#version 130"); // GLSL version 130
    SDL_Event event;
    while (!quit) {
        while (SDL_PollEvent(&event)) {
            if (event.type == SDL_QUIT) {
                printf("SDL_QUIT\n");
                quit = true;
            } else
                handle_key_event(event);
            ImGui_ImplSDL2_ProcessEvent(&event); // Pass events to ImGui
        }
        ImGui_ImplOpenGL3_NewFrame();
        ImGui_ImplSDL2_NewFrame(
#if IMGUI_VERSION_NUM == 19010
            window // ImGui 1.90.1 / SDL2 2.30.0 (Ubuntu 24.04.1) have an 'window' argument
#endif
        );
        ImGui::NewFrame();
        render_gui();
        ImGui::Render();
        glViewport(0, 0, 800, 600);
        glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);
        ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData());
        SDL_GL_SwapWindow(window);
    }
    printf("Shutting down..\n");
    ImGui_ImplOpenGL3_Shutdown();
    ImGui_ImplSDL2_Shutdown();
    ImGui::DestroyContext();
    SDL_GL_DeleteContext(gl_context);
    SDL_DestroyWindow(window);
    SDL_Quit();
    return 0;
}
