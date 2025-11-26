import jwt from "jsonwebtoken";

export const generateToken = (token) => {
    return jwt.sign({ token }, process.env.JWT_SECRET, {
        expiresIn: "7d",
    });
};

/*export const compareToken = async (token) => {
    return await bcrypt.compare(token);
};*/