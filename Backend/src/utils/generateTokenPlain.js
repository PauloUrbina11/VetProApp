import crypto from "crypto";

export const generateTokenPlain = () => {
    return crypto.randomBytes(32).toString("hex");
};
