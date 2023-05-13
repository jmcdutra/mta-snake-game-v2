-- Variaveis gerais
local screenWidth, screenHeight = guiGetScreenSize()

-- Variáveis de configuração
local mapWidth = 20 -- Largura do mapa
local mapHeight = 40 -- Altura do mapa
local mapScale = 20 -- Escala do mapa
local snakeSpeed = 1 -- Velocidade da cobra
local appleValue = 2 -- Tamanho que a cobra ganha ao comer a maçã
local boostValue = 6 -- Tamanho que a cobra ganha ao receber um boost
local boostChance = 0.15 -- Chance de receber um boost (15%)

-- Variáveis do jogo
local snake, apple, score, timer, boosted
local lastUpdateTime = 0
local appleSvg

-- Reinicia o jogo
function resetGame()
    -- Cria a cobra no meio do mapa
    snake = {
        direction = "right",
        body = {
            {x = mapWidth / 2, y = mapHeight / 2}
        }
    }

    -- Coloca a maçã em um lugar aleatório
    apple = {
        x = math.random(1, mapWidth),
        y = math.random(1, mapHeight)
    }

    -- Reinicia a pontuação
    score = 0
end

local mapPixelWidth = mapWidth * mapScale
local mapPixelHeight = mapHeight * mapScale

-- Desenha o jogo
function drawGame()

    -- Atualizador da posição da cobra

    local currentTime = getTickCount()
    print(currentTime, lastUpdateTime, 100 / snakeSpeed)
    if currentTime - lastUpdateTime >= 80 / snakeSpeed then
        updateGame()
        lastUpdateTime = currentTime
    end
    
    -- Desenha o fundo do mapa
    dxDrawRectangle(0, 0, mapPixelWidth + mapScale, mapPixelHeight + mapScale, tocolor(0, 0, 0))

    -- Desenha a cobra
    for i, segment in ipairs(snake.body) do
        local snakeSize = #snake.body
        local ratio = (snakeSize - i + 1) / snakeSize
        local size = (mapScale/2) + (mapScale/2) * ratio -- tamanho do segmento, variando de 25 a 50
        local offset = (mapScale - size) / 2 -- deslocamento para centralizar o segmento menor
        dxDrawRectangle(segment.x * mapScale + offset, segment.y * mapScale + offset, size, size, boosted and tocolor(255 * ratio, 255 * ratio, 0, 255) or tocolor(0, 255 * ratio, 0))
    end

    -- Desenha a maçã
    -- dxDrawRectangle(apple.x * mapScale, apple.y * mapScale, mapScale, mapScale, tocolor(255, 255, 0))
    dxDrawImage(apple.x * mapScale, apple.y * mapScale, mapScale, mapScale, appleSvg)

    -- Desenha a pontuação
    dxDrawRectangle(0, mapPixelHeight + mapScale, mapPixelWidth + mapScale, 30, tocolor(22, 155, 22, 255))
    dxDrawText("Score: " .. score .. ", Size: " .. #snake.body, 0, mapPixelHeight + mapScale, mapPixelWidth + mapScale, 30 + (mapPixelHeight + mapScale), tocolor(255, 255, 255), 1.1, "default-bold", "center", "center")
    
    -- Desenha o BOOST
    if boosted then
        -- Desenha a pontuação
        dxDrawRectangle(0, mapPixelHeight + mapScale + 30, mapPixelWidth + mapScale, 30, tocolor(190, 190, 0, 255))
        dxDrawText("BOOOOOOOOOOOST!", 0, mapPixelHeight + mapScale + 30, mapPixelWidth + mapScale, 30 + (mapPixelHeight + mapScale + 30), tocolor(255, 255, 255), 1.1, "default-bold", "center", "center")
    end
end

-- Atualiza o jogo
function updateGame()
    -- Move a cobra na direção atual
    local head = snake.body[1]
    local newHead
    if snake.direction == "right" then
        newHead = {x = head.x + snakeSpeed, y = head.y}
    elseif snake.direction == "left" then
        newHead = {x = head.x - snakeSpeed, y = head.y}
    elseif snake.direction == "up" then
        newHead = {x = head.x, y = head.y - snakeSpeed}
    elseif snake.direction == "down" then
        newHead = {x = head.x, y = head.y + snakeSpeed}
    end

    -- Verifica se a cobra bateu em si mesma ou na borda do mapa
    for i, segment in ipairs(snake.body) do
        if newHead.x == segment.x and newHead.y == segment.y
            or newHead.x < 1 or newHead.x > mapWidth
            or newHead.y < 1 or newHead.y > mapHeight then
            resetGame()
            return
        end
    end

    -- Insere a nova cabeça no início da cobra
    table.insert(snake.body, 1, newHead)

    -- Verifica se a cobra comeu a maçã
    if newHead.x == apple.x and newHead.y == apple.y then
        -- Aumenta a pontuação
        score = score + 1

        -- Coloca a maçã em um lugar aleatório
        apple = {
            x = math.random(1, mapWidth),
            y = math.random(1, mapHeight)
        }

        -- Aplica o boost de tamanho aleatoriamente
        if math.random() < boostChance then
            --outputChatBox("BOOOOOOOOOOOOOOOOOOOOOOOOOOOOST!!!!!!")
            boosted = true
            --snakeSpeed = snakeSpeed + 0.3

            for i = 1, boostValue do table.insert(snake.body, {x = -1, y = -1}) end
            setTimer(function() 
                boosted = false
                --snakeSpeed = snakeSpeed - 0.3
            end, 1000, 1)
        else
            -- Aumenta o tamanho da cobra
            for i = 1, appleValue do
                table.insert(snake.body, {x = -1, y = -1})
            end
        end
    else
        -- Remove o último segmento da cobra
        table.remove(snake.body)
    end
end

-- Manipula o input do jogador
function handlePlayerInput(key, state)
    if state then
        print("b")
        if (key == "arrow_u" or key == "w") and snake.direction ~= "down" then
            print("c")
            snake.direction = "up"
        elseif (key == "arrow_d" or key == "s") and snake.direction ~= "up" then
            snake.direction = "down"
        elseif (key == "arrow_l" or key == "a") and snake.direction ~= "right" then
            snake.direction = "left"
        elseif (key == "arrow_r" or key == "d") and snake.direction ~= "left" then
            snake.direction = "right"
        end
    end
end


local appleSvg_RawData = [[ <?xml version="1.0" encoding="utf-8"?><svg xml:space="preserve" viewBox="0 0 100 100" y="0" x="0" xmlns="http://www.w3.org/2000/svg" id="圖層_1" version="1.1" width="200px" height="200px" xmlns:xlink="http://www.w3.org/1999/xlink" style="width:100%;height:100%;background-size:initial;background-repeat-y:initial;background-repeat-x:initial;background-position-y:initial;background-position-x:initial;background-origin:initial;background-image:initial;background-color:rgb(255, 255, 255);background-clip:initial;background-attachment:initial;animation-play-state:paused" ><g class="ldl-scale" style="transform-origin:50% 50%;transform:rotate(0deg) scale(0.8, 0.8);animation-play-state:paused" ><path fill="#603813" d="M57.414 16.326c3.974-5.426 9.875-7.021 16.479-8.296 1.826 1.932 2.314 4.131.601 6.721-5.797 1.207-11.11 1.931-15.034 6.365-2.106 2.379-3.818 5.097-5.109 7.997a33.65 33.65 0 0 0-1.605 4.419c-.45 1.571-.266 3.502-2.077 3.908-.428-3.254.711-7.385 1.605-10.478 1.098-3.801 2.798-7.44 5.14-10.636z" style="fill:rgb(96, 56, 19);animation-play-state:paused" ></path> <path fill="#009245" d="M49.551 18.25c-5.452-6.449-14.505-9.632-22.793-8.015-.29 1.714.243 3.466.995 5.033 3.061 6.378 10.108 10.618 17.176 10.337 1.455-.058 2.952-.285 4.339.159 1.387.444 2.612 1.861 2.226 3.265 1.548-3.632.517-7.869-1.943-10.779z" style="fill:rgb(0, 146, 69);animation-play-state:paused" ></path> <path fill="#d96d6d" d="M80.997 32.286a21.347 21.347 0 0 0-6.287-3.619C64.272 24.79 51.506 35 51.506 35s-10.796-9.667-22.462-6.333C17.377 32 13.49 44.335 13.49 54s4.255 18.415 11.135 24.749c4.124 3.797 9.195 6.716 14.854 8.453A40.953 40.953 0 0 0 51.506 89c10.498 0 20.002-3.918 26.881-10.251S89.521 63.665 89.521 54c0-7.622-1.976-16.268-8.524-21.714z" style="fill:rgb(241, 25, 25);animation-play-state:paused" ></path> <metadata xmlns:d="https://loading.io/stock/" style="animation-play-state:paused" ><d:name style="animation-play-state:paused" >apple</d:name> <d:tags style="animation-play-state:paused" >apple,fruit</d:tags> <d:license style="animation-play-state:paused" >by</d:license> <d:slug style="animation-play-state:paused" >4jko51</d:slug></metadata></g><!-- generated by https://loading.io/ --></svg>]]

-- Inicia o jogo
function startGame()
    appleSvg = svgCreate(mapScale, mapScale, appleSvg_RawData)
    resetGame()
    updateGame()
    addEventHandler("onClientRender", root, drawGame)
    addEventHandler("onClientKey", root, handlePlayerInput)
   -- timer = setTimer(updateGame, 100, 0)
end

-- Para o jogo
function stopGame()
    removeEventHandler("onClientRender", root, drawGame)
    removeEventHandler("onClientKey", root, handlePlayerInput)
   -- killTimer(timer)
end

-- Inicia o jogo quando o resource é iniciado
addEventHandler("onClientResourceStart", resourceRoot, startGame)

-- Para o jogo quando o resource é parado
addEventHandler("onClientResourceStop", resourceRoot, stopGame)
