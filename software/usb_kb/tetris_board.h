/*
 * tetris_board.h
 *
 *  Created on: Dec 13, 2017
 *      Author: Mike
 */

#ifndef TETRIS_BOARD_H_
#define TETRIS_BOARD_H_

void initBoard();
void drawBoard();
void updateBoard();
void movePieceLeft();
void movePieceRight();
void addNextPiece();
void rotatePiece();
void checkForRowClear();

extern int score;
extern int level;
#endif /* TETRIS_BOARD_H_ */
