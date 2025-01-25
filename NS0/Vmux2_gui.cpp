#include <imgui.h>
#include <backends/imgui_impl_sdl2.h>
#include <backends/imgui_impl_opengl3.h>
#include <SDL2/SDL.h>
#include <GL/glew.h> // Use GLEW for OpenGL function loading
#include "Vmux2.h"
Vmux2 *top = NULL;
static bool a, b, sel;
void init_top() {
    if (!top) top = new Vmux2;
}
void handle_key_event(SDL_Event& event) {
    if (event.type == SDL_KEYDOWN) {
        if (event.key.keysym.sym == SDLK_a)
            a = !a;
        else if (event.key.keysym.sym == SDLK_b)
            b = !b;
        else if (event.key.keysym.sym == SDLK_s)
            sel = !sel;
    }
}
void render_gui() {
    ImGui::Begin("mux2");
    ImGui::Checkbox("a", &a);ImGui::SameLine();
    ImGui::Checkbox("b", &b);ImGui::SameLine();
    ImGui::Checkbox("sel", &sel);ImGui::SameLine();
    top->a = a;
    top->b = b;
    top->sel = sel;
    top->eval();
    bool y = top->y;
    ImGui::BeginDisabled();ImGui::Checkbox("y", &y);ImGui::EndDisabled();
    ImGui::End();
}

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
    bool running = true;
    while (running) {
        while (SDL_PollEvent(&event)) {
            if (event.type == SDL_QUIT)
                running = false;
            else if (event.key.keysym.sym == SDLK_ESCAPE)
                running = false;
            else
                handle_key_event(event);
            ImGui_ImplSDL2_ProcessEvent(&event); // Pass events to ImGui
        }
        ImGui_ImplOpenGL3_NewFrame();
        ImGui_ImplSDL2_NewFrame(window);
        ImGui::NewFrame();
        render_gui();
        ImGui::Render();
        glViewport(0, 0, 800, 600);
        glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);
        ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData());
        SDL_GL_SwapWindow(window);
    }
    ImGui_ImplOpenGL3_Shutdown();
    ImGui_ImplSDL2_Shutdown();
    ImGui::DestroyContext();
    SDL_GL_DeleteContext(gl_context);
    SDL_DestroyWindow(window);
    SDL_Quit();
    return 0;
}
