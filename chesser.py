import chess
import tkinter as tk
from PIL import Image, ImageTk
import os
import argparse

# Diccionario con las imágenes de las piezas
PIECES = {
    'P': 'images/wP.png',
    'N': 'images/wN.png',
    'B': 'images/wB.png',
    'R': 'images/wR.png',
    'Q': 'images/wQ.png',
    'K': 'images/wK.png',
    'p': 'images/bP.png',
    'n': 'images/bN.png',
    'b': 'images/bB.png',
    'r': 'images/bR.png',
    'q': 'images/bQ.png',
    'k': 'images/bK.png'
}

# Función para obtener la imagen de la pieza
def get_piece_image(piece, square_size):
    try:
        image_path = PIECES[piece]
        img = Image.open(image_path)
        img = img.convert('RGBA')  # Asegurarse de que la imagen tenga transparencia
        img = img.resize((square_size, square_size), Image.NEAREST)  # Redimensionado sin suavizado para pixel art
        return ImageTk.PhotoImage(img)
    except KeyError:
        return None  # No hay pieza en esa casilla

# Función para mostrar el tablero con las piezas y las coordenadas
def create_chessboard_window(board, canvas, images):
    # Colores de las casillas del tablero (madera clara y oscura)
    colors = ['#FA8EC8', '#030b1e']
    square_size = 60  # Tamaño de cada casilla

    # Limpiar el canvas
    canvas.delete("all")
    images.clear()  # Limpiar las imágenes anteriores

    # Dibujar las coordenadas
    for i in range(8):
        # Coordenadas de las filas (1-8)
        canvas.create_text(10, i * square_size + square_size // 2 - 5, text=str(8 - i), fill="black")
        canvas.create_text(8 * square_size + 20, i * square_size + square_size // 2 - 5, text=str(8 - i), fill="black")
        # Coordenadas de las columnas (a-h)
        canvas.create_text(i * square_size + square_size // 2, 8 * square_size + 5, text=chr(ord('a') + i), fill="black")
        canvas.create_text(i * square_size + square_size // 2, 5, text=chr(ord('a') + i), fill="black")

    # Dibujar el tablero y las piezas
    for row in range(8):
        for col in range(8):
            x1 = col * square_size
            y1 = row * square_size
            x2 = x1 + square_size
            y2 = y1 + square_size
            color = colors[(row + col) % 2]
            canvas.create_rectangle(x1, y1, x2, y2, fill=color, outline="black")

            # Obtener la pieza en la casilla y mostrarla
            piece = board.piece_at(chess.square(col, 7 - row))  # Ajuste para la fila 0 en la parte inferior
            if piece:
                img = get_piece_image(piece.symbol(), square_size)
                if img:
                    images.append(img)  # Mantener referencia
                    canvas.create_image(x1 + square_size // 2, y1 + square_size // 2, image=img)

# Función para procesar los movimientos en notación SAN
def process_moves(board, moves, canvas, images, root):
    for move in moves:
        board.push_san(move)  # Realizar el movimiento
        create_chessboard_window(board, canvas, images)  # Redibujar el tablero
        root.after(500, root.update())

# Función principal para iniciar la simulación
def chess_simulation(fen, moves, title):
    # Inicializar el tablero de ajedrez con la posición FEN
    board = chess.Board(fen)

    root = tk.Tk()
    root.title(title)  # Usar el título pasado como argumento

    canvas = tk.Canvas(root, width=8 * 60 + 40, height=8 * 60 + 60)  # Ajustar tamaño del canvas para incluir coordenadas y título
    canvas.pack()

    # Mostrar el título encima del tablero
    canvas.create_text(8 * 60 // 2 + 20, 20, text=title, font=("Arial", 16), fill="black")

    images = []  # Para almacenar las referencias de las imágenes y evitar la recolección de basura

    # Mostrar el tablero inicial
    create_chessboard_window(board, canvas, images)

    # Procesar los movimientos y animarlos
    process_moves(board, moves, canvas, images, root)

    root.mainloop()

# Configurar argparse para manejar los argumentos de línea de comandos
parser = argparse.ArgumentParser(description="Simulación de ajedrez con tablero gráfico.")
parser.add_argument("title", type=str, help="Título a mostrar encima del tablero.")
args = parser.parse_args()

# Secuencia de movimientos en notación SAN (puedes reemplazar esto con tus propios movimientos)
# Obtener la ruta del archivo de ejemplo
file_path = os.path.join(os.path.dirname(__file__), 'ejemplo.txt')

# Leer los movimientos desde el archivo
with open(file_path, 'r') as file:
    moves = file.read().split()

# Posición inicial FEN
fen_position = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"  # FEN del tablero de inicio

# Ejecutar la simulación con la posición inicial FEN, los movimientos y el título
chess_simulation(fen_position, moves, args.title)
