import tkinter as tk
from PIL import Image, ImageTk  # Librería Pillow para redimensionar imágenes
import argparse

def draw_board(canvas, board, images, title):
    canvas.delete("all")
    size = 120  # Tamaño de cada celda
    colors = ["#000000", "#fa8ec8"]  # Colores del tablero
    
    # Dibujar el título
    canvas.create_text(size * 4, 10, text=title, font=("Arial", 20, "bold"))
    
    # Dibujar el tablero
    for row in range(8):
        for col in range(8):
            color = colors[(row + col) % 2]
            x1, y1 = col * size, row * size + 40  # Desplazar el tablero hacia abajo para que no se superponga
            x2, y2 = x1 + size, y1 + size
            canvas.create_rectangle(x1, y1, x2, y2, fill=color, outline=color)

    # Dibujar las piezas
    for row in range(8):
        for col in range(8):
            piece = board[row][col]
            if piece:
                x, y = col * size, row * size + 40
                canvas.create_image(x + size // 2, y + size // 2, image=images[piece])
    
    # Dibujar las coordenadas (columnas y filas)
    for i in range(8):
        # Dibujar columnas (a-h) en la parte superior e inferior
        canvas.create_text(i * size + size // 2, size * 8 + 30, text=chr(i + 97), font=("Arial", 16))
        canvas.create_text(i * size + size // 2, -10 + 40, text=chr(i + 97), font=("Arial", 16))
        # Dibujar filas (1-8) a la izquierda y derecha
        canvas.create_text(-10, i * size + size // 2 + 40, text=str(8 - i), font=("Arial", 16))
        canvas.create_text(size * 8 + 10, i * size + size // 2 + 40, text=str(8 - i), font=("Arial", 16))

def initialize_board():
    """Crea el tablero inicial de ajedrez."""
    board = [[None for _ in range(8)] for _ in range(8)]
    
    # Inicializar peones
    for i in range(8):
        board[1][i] = "white_pawn"  # Peones blancos
        board[6][i] = "black_pawn"  # Peones negros
    
    # Inicializar piezas mayores
    initial_row = [
        "white_rook", "white_knight", "white_bishop", "white_queen",
        "white_king", "white_bishop", "white_knight", "white_rook"
    ]
    board[0] = initial_row
    board[7] = [piece.replace("white", "black") for piece in initial_row]
    
    return board

def move_piece(board, move):
    """Aplica un movimiento básico (simplificado)."""
    start, end = move.split()
    start_col, start_row = ord(start[0]) - ord('a'), 8 - int(start[1])
    end_col, end_row = ord(end[0]) - ord('a'), 8 - int(end[1])
    
    board[end_row][end_col] = board[start_row][start_col]
    board[start_row][start_col] = None

def load_images():
    """Carga las imágenes de las piezas y las redimensiona manteniendo el pixel art."""
    images = {}
    piece_files = {
        "white_king": "white_king.png",
        "white_queen": "white_queen.png",
        "white_rook": "white_rook.png",
        "white_bishop": "white_bishop.png",
        "white_knight": "white_knight.png",
        "white_pawn": "white_pawn.png",
        "black_king": "black_king.png",
        "black_queen": "black_queen.png",
        "black_rook": "black_rook.png",
        "black_bishop": "black_bishop.png",
        "black_knight": "black_knight.png",
        "black_pawn": "black_pawn.png",
    }
    
    for piece, file in piece_files.items():
        # Cargar la imagen original
        original_image = Image.open(file)
        # Redimensionar conservando pixel art
        resized_image = original_image.resize((70, 70), Image.Resampling.NEAREST)
        # Convertir a un formato compatible con tkinter
        images[piece] = ImageTk.PhotoImage(resized_image)
    
    return images


def main():
    parser = argparse.ArgumentParser(description="Juego de Ajedrez paso a paso.")
    parser.add_argument("title", type=str, help="Título para mostrar en el tablero de ajedrez")
    args = parser.parse_args()
    
    moves = ["e2 e4", "e7 e5", "g1 f3", "b8 c6", "d2 d4"]  # Movimientos de ejemplo
    
    # Crear la ventana y el lienzo
    root = tk.Tk()
    root.title("Visualizamos la Apertura paso a paso")  # Establecer el título de la ventana con el parámetro
    size = 125 * 8
    canvas = tk.Canvas(root, width=size, height=size)
    canvas.pack()
    
    # Cargar imágenes
    images = load_images()
    
    # Inicializar el tablero
    board = initialize_board()
    draw_board(canvas, board, images, title=args.title)  # Pasar el título desde la entrada
    
    # Mostrar movimientos paso a paso
    def show_moves(index=0):
        if index < len(moves):
            move_piece(board, moves[index])
            draw_board(canvas, board, images, title=args.title)  # Actualizar con el título
            root.after(1000, show_moves, index + 1)  # Esperar 1 segundo antes del siguiente movimiento
    
    root.after(1000, show_moves)  # Iniciar después de 1 segundo
    root.mainloop()

if __name__ == "__main__":
    main()
