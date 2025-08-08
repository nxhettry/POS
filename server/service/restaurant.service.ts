import Restaurant from "../models/restaurant.models.js";

interface RestaurantUpdateData {
  name?: string;
  address?: string;
  phone?: string;
  email?: string;
  pan?: string;
  website?: string;
  logo?: string;
}

export const updateRestaurantDetailService = async (
  restaurantData: RestaurantUpdateData
) => {
  try {
    const restaurant = await Restaurant.findOne();

    if (!restaurant) {
      const newRestaurant = await Restaurant.create(restaurantData as any);
      return {
        success: true,
        data: newRestaurant,
        message: "Restaurant details created successfully",
      };
    }

    const updatedRestaurant = await restaurant.update(restaurantData);

    return {
      success: true,
      data: updatedRestaurant,
      message: "Restaurant details updated successfully",
    };
  } catch (error: any) {
    throw new Error(`Failed to update restaurant details: ${error.message}`);
  }
};

export const getRestaurantDetailService = async () => {
  try {
    const restaurant = await Restaurant.findOne();

    if (!restaurant) {
      return {
        success: false,
        data: null,
        message: "No restaurant details found",
      };
    }

    return {
      success: true,
      data: restaurant,
      message: "Restaurant details retrieved successfully",
    };
  } catch (error: any) {
    throw new Error(`Failed to get restaurant details: ${error.message}`);
  }
};
