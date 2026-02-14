package utils

import (
	"errors"

	"github.com/golang-jwt/jwt/v5"
)

func VerifyToken(tokenStr, secret, tokenType string) (uint, error) {
	token, err := jwt.Parse(tokenStr, func(_ *jwt.Token) (interface{}, error) {
		return []byte(secret), nil
	})

	if err != nil || !token.Valid {
		return 0, err
	}

	claims, ok := token.Claims.(jwt.MapClaims)
	if !ok {
		return 0, errors.New("invalid token claims")
	}

	jwtType, ok := claims["type"].(string)
	if !ok || jwtType != tokenType {
		return 0, errors.New("invalid token type")
	}

	userID, ok := claims["sub"].(uint)
	if !ok {
		return 0, errors.New("invalid token sub")
	}

	return userID, nil
}
