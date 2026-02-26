package models

import (
	"database/sql"
	"time"

	"gorm.io/gorm"
)

type BaseModel struct {
	ID        int            `gorm:"primaryKey"`
	CreatedAt time.Time      `gorm:"not null" json:"created_at"`
	UpdatedAt time.Time      `gorm:"not null" json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"null" json:"deleted_at"`
}

type MenuContentX struct {
	CustomerID string                 `json:"customer_id"`
	Restaurant Restaurant             `json:"restaurant"`
	Categories []RestaurantCategories `json:"categories"`
	Products   []RestaurantProducts
}

type Restaurant struct {
	Name string `json:"RestaurantName"`
}

type RestaurantCategories struct {
	Id   string `json:"categoryId"`
	Name string `json:"categoryName"`
}

type RestaurantProducts struct {
	Id             string            `json:"productId"`
	CategoryId     string            `json:"categoryId"`
	Name           string            `json:"name"`
	Description    string            `json:"description,omitempty"`
	Portions       RestaurantPortion `json:"portions"`
	VariationGroup []VariationGroup  `json:"variationGroups"`
}

type RestaurantPortion struct {
	Small            string `json:"small,omitempty"`
	Medium           string `json:"medium,omitempty"`
	Large            string `json:"large,omitempty"`
	Standard         string `json:"standard,omitempty"`
	OneQuarterLiter  string `json:"one_quarter_liter,omitempty"`
	OneThirdLiter    string `json:"one_third_liter,omitempty"`
	OneHalfLiter     string `json:"one_half_liter,omitempty"`
	SevenTenthsLiter string `json:"seven_tenths_liter,omitempty"`
	OneLiter         string `json:"one_liter,omitempty"`
	TwoLiters        string `json:"two_liters,omitempty"`
	TwoAndHalfLiters string `json:"two_and_half_liters,omitempty"`
}

type VariationGroup struct {
	Name       string `json:"name,omitempty"`
	Label      string `json:"label,omitempty"`
	Min        int    `json:"min,omitempty"`
	Max        int    `json:"max,omitempty"`
	Variations []Variation
}

type Variation struct {
	Label  string           `json:"label,omitempty"`
	Prices []VariationPrice `json:"prices,omitempty"`
}

type VariationPrice struct {
	Name  string  `json:"name"`
	Price float64 `json:"price"`
}

type PromptResult struct {
	Counter int    `gorm:"not null" json:"counter"`
	Content string `gorm:"not null" json:"content"`
}

type SaveResult struct {
	Code    int    `gorm:"not null" json:"code"`
	Message string `gorm:"not null" json:"message"`
}

type MenuTask struct {
	//BaseModel
	ID       int    `gorm:"primaryKey;column:id" json:"id"`
	ClientID int    `gorm:"column:client_id;not null" json:"client_id"`
	Task     string `gorm:"column:task;not null" json:"task"`
	Status   int    `gorm:"column:status;not null, default:0" json:"status"` // 0: pending, 1: running, 2: completed, 3: error, 4: cancel
	Message  string `gorm:"column:message;null" json:"message"`
}

type MenuContent struct {
	BaseModel
	ClientID        int            `gorm:"not null" json:"client_id"`
	FileName        string         `gorm:"not null" json:"file_name"`
	ProductName     string         `gorm:"not null" json:"product_name"`
	ProductID       string         `gorm:"not null" json:"product_id"`
	ProductCategory string         `gorm:"not null" json:"product_category"`
	Content         string         `gorm:"not null" json:"content"`
	ContentVector   sql.NullString `gorm:"null" json:"content_vector"`
}

type Client struct {
	ID         int    `gorm:"not null" json:"id"`
	CustomerID string `gorm:"not null" json:"customer_id"`
}

type TEIEmbeddingRequest struct {
	Inputs string `json:"inputs"`
}
