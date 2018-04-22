/*
 * tetris_board.c
 *
 *  Created on: Dec 13, 2017
 *      Author: Mike
 */

#include "tetris_board.h"
#include "system.h"

#define block_data		(volatile int*) 	BLOCK_DATA_BASE
#define drawing_status	(volatile char*)	DRAWING_STATUS_BASE
#define random_seed		(volatile char*)	RANDOM_SEED_BASE
#define level_score		(volatile int*) 	LEVEL_SCORE_BASE
#define BOARD_X_WIDTH 10
#define BOARD_Y_HEIGHT 24
#define BOARD_LEFT_OFFSET 240
#define BOARD_TOP_OFFSET 48
typedef union bd_u {
	unsigned int data_packed:32;
	struct {
		unsigned int x_pos:10;
		unsigned int y_pos:10;
		unsigned int color:4;
		unsigned int draw:1;
		unsigned int clear:1;
		unsigned int curr_frame:1;
		unsigned int reserved:5;
	} membs;
} bd_u;

int current_frame = 0;
char board[10][24];
char fallingPieceX[4];
char fallingPieceY[4];
char fallingPieceType;
char has_landed;
int piecesAdded;
void initBoard(){
	int boardX, boardY;
	piecesAdded = 0;
	level = 1;
	score = 0;
	for(boardX = 0; boardX < BOARD_X_WIDTH; boardX++){
		for(boardY = 0; boardY < BOARD_Y_HEIGHT; boardY++){
			board[boardX][boardY] = 0;
		}
	}
	addNextPiece();
}
//Board: 0 = Empty
//1 = S (Red)
//2 = J (Orange)
//3 = Square (Yellow)
//4 = Z (Green)
//5 = Straight (Blue)
//6 = T (Purple)
//7 = L (Light Blue)
void addNextPiece(){
	int random_val = (*random_seed)/2;
	piecesAdded++;
	if(piecesAdded == ((level*10)+15)){
		level++;
		piecesAdded = 0;
	}
	switch(random_val){
		case 1: fallingPieceX[0] = 4; fallingPieceX[1] = 5; fallingPieceX[2] = 5; fallingPieceX[3] = 6; //S peice
				fallingPieceY[0] = 1; fallingPieceY[1] = 1; fallingPieceY[2] = 0; fallingPieceY[3] = 0;
				break;
		case 2: fallingPieceX[0] = 4; fallingPieceX[1] = 4; fallingPieceX[2] = 5; fallingPieceX[3] = 6; //J peice
				fallingPieceY[0] = 0; fallingPieceY[1] = 1; fallingPieceY[2] = 1; fallingPieceY[3] = 1;
				break;
		case 3: fallingPieceX[0] = 4; fallingPieceX[1] = 4; fallingPieceX[2] = 5; fallingPieceX[3] = 5; //Square peice
				fallingPieceY[0] = 0; fallingPieceY[1] = 1; fallingPieceY[2] = 0; fallingPieceY[3] = 1;
				break;
		case 4: fallingPieceX[0] = 4; fallingPieceX[1] = 5; fallingPieceX[2] = 5; fallingPieceX[3] = 6; //Z peice
				fallingPieceY[0] = 0; fallingPieceY[1] = 0; fallingPieceY[2] = 1; fallingPieceY[3] = 1;
				break;
		case 0:
		case 5: fallingPieceX[0] = 3; fallingPieceX[1] = 4; fallingPieceX[2] = 5; fallingPieceX[3] = 6; //Straight peice
				fallingPieceY[0] = 0; fallingPieceY[1] = 0; fallingPieceY[2] = 0; fallingPieceY[3] = 0;
				break;
		case 6: fallingPieceX[0] = 4; fallingPieceX[1] = 5; fallingPieceX[2] = 5; fallingPieceX[3] = 6; //T peice
				fallingPieceY[0] = 0; fallingPieceY[1] = 0; fallingPieceY[2] = 1; fallingPieceY[3] = 0;
				break;
		case 7: fallingPieceX[0] = 4; fallingPieceX[1] = 5; fallingPieceX[2] = 6; fallingPieceX[3] = 6; //L peice
				fallingPieceY[0] = 1; fallingPieceY[1] = 1; fallingPieceY[2] = 1; fallingPieceY[3] = 0;
				break;
	}
	fallingPieceType = (char) random_val ? random_val : 5;
	printf("New piece added: %d\n", (int) fallingPieceType);
	int i;
	for (i = 0; i<4; i++){
		board[(int) fallingPieceX[i]][(int) fallingPieceY[i]] = fallingPieceType;
	}
	has_landed = 0;
}

void updateBoard(){
	//Check if next move would be legal
	//If so, then erase the current location and move all the poeces down by 1
	if(has_landed==0){ //Only update the board if a peice is falling
		int i;
		for (i = 0; i<4; i++){
			board[(int)fallingPieceX[i]][(int)fallingPieceY[i]] = 0;
		}
		int min_landing = BOARD_Y_HEIGHT;
		for (i = 0; i<4; i++){
			if(board[(int) fallingPieceX[i]][(int) fallingPieceY[i]+1] != 0 || (int) fallingPieceY[i]+1 >= BOARD_Y_HEIGHT){
				has_landed = 1;
				if(min_landing > fallingPieceY[i]){
					min_landing = fallingPieceY[i];
				}
			}
		}
		if(has_landed && min_landing <= 1){
			processLoss();
			return;
		}
		for (i = 0; i<4; i++){
			if(has_landed==0){ //Next move down is still legal, move the piece down
				fallingPieceY[i]++;
			}
			board[(int) fallingPieceX[i]][(int) fallingPieceY[i]] = fallingPieceType;
		}
	}
	if(has_landed==1){
		//printf("Piece Landed, adding new piece: %d\n",(int) has_landed);
		checkForRowClear();
		addNextPiece();
	}
}

void processLoss(){
	int loop_flash;
	for(loop_flash = 0; loop_flash < 10; loop_flash++){
		int boardX, boardY;
		for(boardX = 0; boardX < BOARD_X_WIDTH; boardX++){
			for(boardY = 0; boardY < BOARD_Y_HEIGHT; boardY++){
				board[boardX][boardY] = -1;
			}
		}
		drawBoard();
		usleep(20000);
		for(boardX = 0; boardX < BOARD_X_WIDTH; boardX++){
			for(boardY = 0; boardY < BOARD_Y_HEIGHT; boardY++){
				board[boardX][boardY] = -2;
			}
		}
		drawBoard();
		usleep(20000);
	}
	initBoard();
};

void checkForRowClear(){
	int boardX, boardY;
	int has_empty;
	for(boardY = 0; boardY < BOARD_Y_HEIGHT; boardY++){
		has_empty = 0;
		for(boardX = 0; boardX < BOARD_X_WIDTH; boardX++){
			if(board[boardX][boardY] == 0)
				has_empty = 1;
		}
		if(!has_empty){
			score += 1;
			//Flash the row white, then black, then white again, then clear it. Pause the game while doing this:
			for(boardX = 0; boardX < BOARD_X_WIDTH; boardX++){
				board[boardX][boardY] = -1;
			}
			drawBoard();
			usleep(10000);
			for(boardX = 0; boardX < BOARD_X_WIDTH; boardX++){
				board[boardX][boardY] = -2;
			}
			drawBoard();
			usleep(10000);
			for(boardX = 0; boardX < BOARD_X_WIDTH; boardX++){
				board[boardX][boardY] = -1;
			}
			drawBoard();
			usleep(10000);
			for(boardX = 0; boardX < BOARD_X_WIDTH; boardX++){
				board[boardX][boardY] = -2;
			}
			drawBoard();
			usleep(10000);
			for(boardX = 0; boardX < BOARD_X_WIDTH; boardX++){
				board[boardX][boardY] = -1;
			}
			drawBoard();
			usleep(10000);

			int boardYShift;
			for(boardYShift = boardY; boardYShift>0; boardYShift--){
				for(boardX = 0; boardX < BOARD_X_WIDTH; boardX++){
					board[boardX][boardYShift] = board[boardX][boardYShift-1];
					board[boardX][boardYShift-1] = 0;
				}
			}
			boardY--;
		}
	}
}

void rotatePiece(){
	char fallingPieceCheckX[4];
	char fallingPieceCheckY[4];
	int i;
	int is_valid = 1;
	for (i = 0; i<4; i++){
		board[fallingPieceX[i]][fallingPieceY[i]] = 0;
		fallingPieceCheckX[i] = fallingPieceY[i]-fallingPieceY[1] + fallingPieceX[1];
		fallingPieceCheckY[i] = -(fallingPieceX[i]-fallingPieceX[1]) + fallingPieceY[1];
	}
	for (i = 0; i<4; i++){
		if(board[fallingPieceCheckX[i]][fallingPieceCheckY[i]] != 0 || fallingPieceCheckX[i] < 0 || fallingPieceCheckX[i] >= BOARD_X_WIDTH
																	|| fallingPieceCheckY[i] < 0 || fallingPieceCheckY[i] >= BOARD_Y_HEIGHT){
			is_valid = 0;
			break;
		}
	}
	for (i = 0; i<4; i++){
		if(is_valid){ //Next move right is still legal, move the piece down
			fallingPieceX[i] = fallingPieceCheckX[i];
			fallingPieceY[i] = fallingPieceCheckY[i];
		}
		board[fallingPieceX[i]][fallingPieceY[i]] = fallingPieceType;
	}

}

//move the piece left if possible
void movePieceLeft(){
	int i;
	int is_valid = 1;
	for (i = 0; i<4; i++){
		board[fallingPieceX[i]][fallingPieceY[i]] = 0;
	}
	for (i = 0; i<4; i++){
		if(board[fallingPieceX[i]-1][fallingPieceY[i]] != 0 || fallingPieceX[i]-1 < 0){
			is_valid = 0;
			break;
		}
	}
	for (i = 0; i<4; i++){
		if(is_valid){ //Next move right is still legal, move the piece down
			fallingPieceX[i]-=1;
		}
		board[fallingPieceX[i]][fallingPieceY[i]] = fallingPieceType;
	}
}
//Move the piece right if possible, can occur at any time
void movePieceRight(){

	int i;
	int is_valid = 1;
	for (i = 0; i<4; i++){
		board[fallingPieceX[i]][fallingPieceY[i]] = 0;
	}
	for (i = 0; i<4; i++){
		if(board[fallingPieceX[i]+1][fallingPieceY[i]] != 0 || fallingPieceX[i]+1 >= BOARD_X_WIDTH){
			is_valid = 0;
			break;
		}
	}
	for (i = 0; i<4; i++){
		if(is_valid){ //Next move right is still legal, move the piece down
			fallingPieceX[i]+=1;
		}
		board[fallingPieceX[i]][fallingPieceY[i]] = fallingPieceType;
	}

}

void drawBoard(){
	//Clear screen and wait for completion
	bd_u data;
	int boardX, boardY;
	int x_pos, y_pos;
	data.data_packed = 0;
	data.membs.curr_frame = current_frame;
	*block_data = data.data_packed;
	*level_score = (level << 28) + (score);
	while((*drawing_status & 3) != 3);
	data.membs.clear = 1;
	*block_data = data.data_packed;
	while((*drawing_status & 2) != 2); // Check for cleared screen completion
	data.membs.clear = 0;
	for(boardX = 0; boardX < BOARD_X_WIDTH; boardX++){
		for(boardY = 0; boardY < BOARD_Y_HEIGHT; boardY++){
			x_pos = boardX*16 + BOARD_LEFT_OFFSET;
			y_pos = boardY*16 + BOARD_TOP_OFFSET;
			data.membs.x_pos = x_pos;
			data.membs.y_pos = y_pos;
			data.membs.color = board[boardX][boardY]+2;
			data.membs.draw = 1;
			*block_data = data.data_packed;
			while((*drawing_status & 1) != 1); //Check that the block has finished drawing
			data.membs.draw = 0;
			*block_data = data.data_packed;
		}
	}
	current_frame = current_frame ^ 1;
	data.membs.curr_frame = current_frame;
	*block_data = data.data_packed;



}
